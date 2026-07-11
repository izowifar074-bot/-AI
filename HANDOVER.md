# 交接报告：PVP 中尸壳频繁坠落 / 自救不够强

## 问题现象
`/function smartz:test_pvp` 生成的两只尸壳在悬空平台上 PVP 时**经常被打下平台后坠落身亡**，自救（`ai/rescue`）没能把它们救回来。用户怀疑"冷却太长"。

## 结论先行（三条根因，按影响排序）
1. **自救只认脚下同层（feet-1）的锚点，看不到"头顶/上方"的平台** —— 尸壳被击退离开平台、只要下坠 1 格，它刚才站的平台就位于它 feet 层或更上方，而 `rescue_ray` 只在 **feet-1** 找实体方块，于是四向都找不到锚点，`#rbest` 保持 99，不铺路，直接摔死。**这是主因。**
2. **自救成功后冷却 10（=40gt=2 秒）过长，且与其它建造动作共用一个 `sz.cool`** —— PVP 里 2 秒内往往又被击退一次，此时冷却未回，救不了。
3. **自救每 4gt 才评估一次** —— 被击退后往往已坠 2~3 格才轮到评估，叠加根因 1 更救不回。

---

## 架构速览（下一个模型需要的上下文）
- 只有 **尸壳(husk)** 有 AI。命名空间 `smartz`，全部状态寄宿在少量记分板上（详见 `README.md` 的"状态模型"）。
- 调度：`tick.mcfunction` 分频 —— 1gt `pvp/attack`（出手+控距步法）、4gt `ai/core`（主循环）、8gt `ai/stuck`（地形决策）、20gt `sense`/`swarm`。
- **地形动作全部共用一个 `@s sz.cool` 冷却分数**，在 `core.mcfunction:15` 每 4gt 递减 1。谁设它就冻结所有建造：
  - `rescue` 成功：`sz.cool 10`（`ai/rescue.mcfunction:49`）
  - `descend` 跳崖：`sz.cool 4`（`ai/descend.mcfunction:39`）
  - `bridge` 铺块：`sz.cool 2`
  - `pillar` 垫高：`sz.cool 1`
- 两套"接住下坠"机制：
  - `ai/build/catch` —— **贴结构攀爬**时接住（要求目标在上方≥2 且四邻有实体方块 `#sup`）。PVP 平台场景不满足（目标不在上方）。
  - `ai/rescue` —— **虚空自救**（本报告主角）。

## 自救（rescue）当前实现与关键限制
文件：`ai/rescue.mcfunction`、`ai/rescue_ray.mcfunction`、`ai/rescue_lay.mcfunction`（纯位置步进，无新实体，无新记分板）。

**触发**（`rescue.mcfunction:13-27`）：冷却就绪 + 脚下 1~3 格皆空 + 脚下 4 格内无安全落点(`drop_probe`) + 目标不在正下方。

**方形气球找墙**（`rescue_ray.mcfunction`）：以脚为中心，4 基向（`rotated 0/90/180/270` + `^ ^ ^1` 步进）同步外扩，半径上限 6，取切比雪夫最近命中。
- **关键限制**：命中判定**只认 `~ ~-1 ~`（feet-1 同层）**（`rescue_ray.mcfunction:12`）。这是上一次为修"凭空放块"引入的——只有同层锚点才能保证 feet-1 的桥面对面连上、不悬空。**副作用就是根因 1**：救不了已经掉到平台下方的尸壳。

**铺路**（`rescue_lay.mcfunction`）：沿命中方向在 feet-1 铺一条圆石直路（从脚下第 0 格铺到墙），落桥逃生。

### 核心约束（用户已澄清 —— 原"矛盾"已解除）
> 用户明确：**唯一禁止的是"悬空放置"——即放出一个当下四周（含上下左右前后 6 面）都不挨任何已有方块的孤立方块。** 除此之外**不限速率、不限数量**：只要每一块新方块都贴着某个已有方块的边，就可以在极短时间内连续大量自救放块。
>
> 这把问题从"接住 vs 不凭空的取舍"变成了纯粹的**"从锚点向外生长的连通铺块"**：
> - 允许：从平台边缘/任何相邻实体方块出发，一块接一块（每块都与前一块或已有结构面接）快速铺出柱、阶梯、桥，把尸壳送回安全处——哪怕一刻放很多块也行。
> - 禁止：在半空放一个四周皆空、够不到任何东西的孤立方块（例如当前 bug：feet-1 平桥够不到低台，整条悬空）。
>
> 因此推荐做法：**自救每块放置前都校验"该位置 6 邻中至少有一个实体方块"**（有锚点才放），并从尸壳当前位置向已探测到的平台/墙**逐格连通生长**（可升可降可拐弯），不再拘泥于 feet-1 单层平铺。冷却可直接去掉或大幅降低（用户不限速）。

## 建议排查/修复方向（用户已放宽约束后，推荐按此改）
1. **改为"从锚点连通生长"的自救（正道）**：放弃 feet-1 单层平铺。改成：探测尸壳周围（含上方，因为它常掉在平台下方）最近的实体方块作锚，然后**逐格铺一条连通路径回到该锚/平台**（柱、阶梯、桥皆可，可升可降可拐弯）。**硬约束**：每块放置前校验其 6 邻至少有一个实体方块（`unless block <各邻> replaceable` 命中任一即可放），永不放孤立块。这同时解决根因 1 和"凭空"。
2. **去掉/大幅降低自救冷却**：用户不限速率。可直接删掉 `rescue.mcfunction:49` 的 `sz.cool 10`，或给自救用**独立冷却分数**（不与 `bridge`/`descend` 的 `sz.cool` 混用），甚至每刻可放。解决根因 2。
3. **提高自救评估频率**：把 `rescue` 从 `core`(4gt) 提到由 `tick`/`pvp/attack` 每 1gt 驱动，离台当刻即救。解决根因 3。
4. **"离台即补"预防式（现在明确可行）**：feet-1 由实变空的那一刻，若脚正下方那一格的**任一 6 邻**（尤其刚离开的平台边）有实体方块，立即补一块恢复立足点——因为它贴着平台边，不算悬空，符合用户约束。比"坠落后再救"更早、更稳。
5. **可选**：测试台 `test_pvp` 是 1 格薄悬空台，可维持不变（正好压力测试自救）；也可给它加一圈护栏方便观战。

> 实现提示：MC 指令里判"6 邻有无实体方块"可用一串 `execute unless block ~1 ~ ~ #minecraft:replaceable ... run <set 有锚标记>`（6 个方向 + `~ ~1 ~`/`~ ~-1 ~`），任一非 replaceable 即视为有锚。放块前 gate 该标记即可保证不悬空。

## 相关文件清单
- 自救：`data/smartz/function/ai/rescue.mcfunction` / `rescue_ray.mcfunction` / `rescue_lay.mcfunction`
- 落点扫描（被自救复用）：`ai/drop_probe.mcfunction`
- 攀爬接住：`ai/build/catch.mcfunction`
- 主循环与冷却递减：`ai/core.mcfunction`（rescue 在 line 12 调用；cool 在 line 15 递减）
- 冷却设置点：`rescue.mcfunction:49`、`descend.mcfunction:39`、`build/bridge.mcfunction`、`build/pillar.mcfunction`
- PVP：`ai/pvp/attack.mcfunction`（控距步法+出手）、`pvp/main.mcfunction`、`pvp/pearl_jump.mcfunction`
- 测试指令：`data/smartz/function/test_pvp.mcfunction`

## 验证方法
本仓库环境无法运行 MC。改完后用 `/function smartz:test_pvp`（旁观模式观战）验证：两只尸壳互相击退坠落时应能自救回台，且不出现四周无依靠的孤立浮空方块。

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

### 核心矛盾（必须由下一个模型权衡解决）
> **"永远接住坠向虚空的尸壳" 与 "永不放置四周无依靠的孤立方块(凭空)" 本质冲突。**
>
> 在开阔虚空正上方接住一只下坠尸壳，物理上就**必须**在它脚下放一个当下四周皆空的方块——这正是用户明确反对的"凭空"。当前代码选择了"不凭空"，代价是救不回掉出平台的尸壳。
>
> 可能的调和方向：自救不应只在 feet-1 平铺，而应**向上/四周探测到它刚离开的平台**，然后铺**通往那个平台的阶梯/柱+桥**（每块都连着已有结构，不凭空），把尸壳送回平台高度——而不是在半空平铺一条够不到任何东西的桥。

## 建议排查/修复方向（供参考，最终由下一个模型定夺）
1. **让自救能锚定上方的平台**：`rescue_ray` 恢复对 feet / feet-2 / feet-3 甚至更高层的探测，但 `rescue_lay` 改为**按命中的真实高度铺阶梯**（升/降），保证每块都与锚点/前一块面接——既救得回，又不凭空。这是解决根因 1 的正道。
2. **给自救独立、更短的冷却**：新增一个专用冷却分数（或把 `sz.cool 10` 降到 2~4），避免与 `bridge`/`descend` 抢同一个 `sz.cool` 而被连带冻结。解决根因 2。
3. **提高自救评估频率**：把 `rescue` 从 `core`(4gt) 提到由 `tick`/`pvp/attack` 每 1gt 驱动（离开平台当刻即救）。解决根因 3。
4. **"离台即补"预防式**：检测到 feet-1 由实变空（刚踏空/被击退出边缘）的**那一刻**立即在脚下补块恢复立足点——比"坠落后再救"更早。但注意：孤立平台正上方这么做会放"凭空"块，需和用户确认"脚下正下方接一块"算不算他反对的凭空（他之前反对的是**悬空一条够不到任何东西的桥**，脚下正下方接一块或许可接受——**建议先找用户确认边界**）。
5. **测试场景本身**：`test_pvp` 的平台是 1 格薄的 5×5 悬空台，一旦坠落其下方 6 格内 feet-1 层确实空无一物，自救先天没锚点。可考虑测试台加护栏/加厚，或把"救回原平台"作为目标（见方向 1）。

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

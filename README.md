# 智能僵尸 AI 数据包（Smart Zombie AI）

适用版本：**Minecraft Java 1.21.10**（`pack_format: 89`）

让所有僵尸拥有接近玩家的智能：隔墙索敌、挖方块破墙、定向搭路、垫方块爬高台、
群体情报共享围攻、蛇皮走位闪避弓箭、规避岩浆等危险，以及持剑持盾的
PVP 近战系统——攻击只在僵尸准星真正对准你时命中（射线判定，无杀戮光环）。

## 安装

1. 将整个文件夹（含 `pack.mcmeta`）放入存档的 `world/datapacks/` 目录
2. 游戏内执行 `/reload`
3. 看到聊天栏出现加载成功提示即生效

## 游戏内开关（翻转式：执行一次开↔关切换）

| 命令 | 作用 |
|---|---|
| `/function smartz:toggle/master` | 总开关 |
| `/function smartz:toggle/dig` | 挖掘方块 |
| `/function smartz:toggle/build` | 放置方块（搭路/垫高/跳崖） |
| `/function smartz:toggle/swarm` | 群体协作 |
| `/function smartz:toggle/dodge` | 闪避走位 |
| `/function smartz:toggle/pvp` | PVP 近战系统 |
| `/function smartz:uninstall` | 完全卸载（清除记分板/标签/修饰符/锚点） |

> 从旧版本升级：先用旧数据包执行一次 `/function smartz:uninstall`
> 清掉旧记分板，再覆盖文件 `/reload`。

## 测试清单

- [ ] `/datapack list` 中数据包已启用，`/reload` 后出现加载消息
- [ ] 用墙把自己和僵尸隔开（32 格内）→ 数秒内僵尸隔墙锁定你并开始挖墙（有挖掘音效和粒子，方块分段破坏）。嗅探锁定的瞬间僵尸会闪一下红色受击光，属正常现象
- [ ] 潜行状态下隔墙站在 12 格外 → 僵尸不会发现你；走近到 12 格内会被"嗅到"
- [ ] 站上 3 格高的柱子 → 僵尸垫方块爬上来；攀爬全程它不会走歪或自己走下塔（攀爬时原版走动被冻结）
- [ ] 隔沟搭路时 → 僵尸放一块走一步、笔直向你推进，不会被原版寻路带下桥
- [ ] 在空中横向搭路移动 → 僵尸爬塔追击时不再跳回地面，走出斜向阶梯跟着你走（坠落会被自动垫砖接住）；在开阔地它不会凭空乱垒浮空方块（仅贴着已有结构才续接）
- [ ] 你在低处、僵尸在高台边缘 → 它直接跳下来追你（能承受的落差内；不会跳岩浆/深渊）
- [ ] 你在低处、僵尸在全封闭的天花板/平台上（无边可跳）→ 它横移到你正上方拆脚下方块天降
- [ ] 隔空搭路快到你身边时 → 僵尸会把最后的间隙补满，不会停在一格之外发呆
- [ ] 隔一条 3 格宽的沟 → 僵尸朝你的方向逐格铺路过来（斜向时走折线）
- [ ] 绕自己挖一圈 1 格宽的壕沟 → 僵尸会把沟填平走过来
- [ ] 手持弓瞄准远处僵尸 → 僵尸左右蛇皮走位
- [ ] 一只僵尸发现你 → 40 格内所有僵尸（含隔墙的）同时锁定你并加速围攻
- [ ] 僵尸不会主动走进岩浆/仙人掌
- [ ] 僵尸持铁剑+盾牌；近身时贴无敌帧连续挥砍（引擎上限攻速），一击约 3.5 颗心，出刀距离 3 格与玩家一致
- [ ] 近战圈内它会控距走位：你贴脸它小步后撤拉刀距、中距离绕着你转圈、你拉开它小步进逼——全程平滑滑步，不悬空、不瞬移
- [ ] 连续快砍僵尸两刀 → 它立刻响盾格音效并进入减伤格挡（约 1 秒不还手，3 秒内不重复格挡）
- [ ] 拉开 16 格以上 → 它掏出末影珍珠掷向你，约 0.6 秒后闪现到你面前（自受摔落伤害；每只 2 分钟一次）
- [ ] 它搭路/爬塔时手里握着圆石，近战持剑
- [ ] 平地/起伏地形追击时不再沿途乱放方块；追不上疾跑玩家时也不搭（只有真正被挡住才动工）
- [ ] 举盾正对僵尸 → 攻击被格挡；但僵尸会环绕走位试图绕到侧后
- [ ] 绕到僵尸背后贴脸 → 它没转过身之前打不到你（准星射线判定，无杀戮光环）
- [ ] 疾跑逃离到 4~9 格 → 僵尸明显提速追击

## 架构总览

```
data/
  minecraft/tags/function/     # load/tick 挂接点（已完成，勿改）
  smartz/
    function/
      load.mcfunction          # 建 10 个记分板、常量、默认配置
      tick.mcfunction          # 分频调度器：1gt 出手 / 4gt 主循环 / 8gt 受阻 / 20gt 嗅探警报
      init.mcfunction          # 新僵尸初始化：属性/装备/编号/基线
      uninstall.mcfunction     # 完全卸载
      toggle/                  # 6 个翻转式开关（master/dig/build/swarm/dodge/pvp）
      ai/
        core.mcfunction        # 主循环(4gt)：调度子模块 + 内联危险规避
        sense.mcfunction       # 穿墙嗅探：32格索敌（潜行12格）
        stuck.mcfunction       # 受阻检测与全部地形决策（含攀爬模式进入）
        climb_off.mcfunction   # 退出攀爬模式（多处调用，保留为函数）
        descend.mcfunction     # 跳崖下追：四邻找开放落沿直接跳
        drop_probe.mcfunction  # 落点扫描（递归）
        dodge.mcfunction       # 对弓走位（近战让位给控距步法）
        dig/decide.mcfunction  # 挖掘决策：眼向射线选块
        dig/start.mcfunction   # 挖掘启动：marker 配对（decide/down 共用）
        dig/down.mcfunction    # 天降打击（descend 全部否决时的兜底）
        dig/mine.mcfunction    # 分段挖掘执行
        build/pillar.mcfunction# 垫方块爬高
        build/bridge.mcfunction# 定向搭路（洞深>=2 才铺 + 踏步跟进）
        build/catch.mcfunction # 坠落拦截（贴结构+目标高>=2 才垫）
        swarm/alert.mcfunction # 警报：咆哮 + 目标传染广播
        swarm/respond.mcfunction # 响应：提速 + 建立穿墙仇恨
        pvp/main.mcfunction    # 行为层(4gt)：举盾/换手/追击/珍珠（guard与掷珍珠已内联）
        pvp/attack.mcfunction  # 出手层(1gt)：控距步法 + 瞄准射线
        pvp/ray.mcfunction     # 准星射线（递归）
        pvp/hit.mcfunction     # 命中结算
        pvp/pearl_jump.mcfunction # 珍珠落点闪现
    tags/block/
      unbreakable.json         # 挖掘黑名单（基岩、黑曜石等）
      soft.json                # 软方块（挖得更快）
    predicate/
      aiming_player.json       # 检测持弓/弩的玩家
      sneaking.json            # 检测潜行中的玩家（嗅探降距用）
      sprinting.json           # 检测疾跑中的玩家（追击判定用）
```

## 状态模型（10 个记分板）

设计原则：记分板数量 = 每只僵尸需要的独立状态数。全局变量、常量、
配置项都是 `#` 假人分数，全部寄宿在 `sz.ai` 上，不占额外记分板；
珍珠的"起手"与"冷却"永不同时存在，用一个分数的正负半轴合并。

| 记分板 | 每僵尸状态 | 兼载的假人 |
|---|---|---|
| `sz.ai` | 受阻计数（分层：≥2 决策 / ≥8 升级 / ≥12 重置基线） | 全部：`#tick` 时钟、`#c*` 常量、`#master/#dig/#build/#swarm/#dodge/#pvp` 配置、各临时变量 |
| `sz.id` | 唯一编号（挖掘 marker 配对、走位相位） | — |
| `sz.mine` | 挖掘进度倒计时 | — |
| `sz.cool` | 地形动作冷却（垫高/搭路/跳崖） | — |
| `sz.atk` | 出手冷却（刻级） | — |
| `sz.hurt` | 受击连招计数（≥20 举盾；负值=举盾冷却） | — |
| `sz.hp` | 上次采样血量 ×10（真实受击检测） | — |
| `sz.pearl` | 珍珠状态（正=起手倒计时 / 负=冷却恢复 / 0=就绪） | — |
| `sz.dmin` | 与目标的历史最近距离²（进展基线） | — |
| `sz.dprev` | 上一采样距离²（远离豁免） | — |

## 实体标签约定

| 标签 | 含义 |
|---|---|
| `sz.init` | 已完成初始化的僵尸 |
| `sz.alerted` | 已发现玩家、处于警报状态的僵尸 |
| `sz.mining` | 正在挖掘中的僵尸 |
| `sz.vip` | （玩家，瞬时）警报者的目标，用于向同伴传染仇恨 |
| `sz.climb` | 攀爬模式中的僵尸（原版走动被冻结，防走歪坠落） |
| `sz.pave` | 搭路惯性：连续步进中的僵尸（成功自打/失败自摘） |
| `sz.aim` | （玩家，瞬时）PVP 瞄准/步法的目标锚点 |
| `sz.tpme` | （僵尸，瞬时）珍珠闪现的自身锚点 |

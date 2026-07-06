# 智能僵尸 AI 数据包（Smart Zombie AI）

适用版本：**Minecraft Java 1.21.10**（`pack_format: 89`）

让所有僵尸拥有接近玩家的智能：隔墙索敌、挖方块破墙、定向搭路、垫方块爬高台、
群体情报共享围攻、蛇皮走位闪避弓箭、规避岩浆等危险，以及持剑持盾的
PVP 近战系统——攻击只在僵尸准星真正对准你时命中（射线判定，无杀戮光环）。

## 安装

1. 将整个文件夹（含 `pack.mcmeta`）放入存档的 `world/datapacks/` 目录
2. 游戏内执行 `/reload`
3. 看到聊天栏出现加载成功提示即生效

## 游戏内开关

| 命令 | 作用 |
|---|---|
| `/function smartz:config/master_on` / `master_off` | 总开关 |
| `/function smartz:config/dig_on` / `dig_off` | 挖掘方块 |
| `/function smartz:config/build_on` / `build_off` | 放置方块（搭桥/垫高） |
| `/function smartz:config/swarm_on` / `swarm_off` | 群体协作 |
| `/function smartz:config/dodge_on` / `dodge_off` | 闪避与走位 |
| `/function smartz:config/pvp_on` / `pvp_off` | PVP 近战系统 |
| `/function smartz:uninstall` | 完全卸载（清除记分板与标签） |

## 测试清单

- [ ] `/datapack list` 中数据包已启用，`/reload` 后出现加载消息
- [ ] 用墙把自己和僵尸隔开（32 格内）→ 数秒内僵尸隔墙锁定你并开始挖墙（有挖掘音效和粒子，方块分段破坏）。嗅探锁定的瞬间僵尸会闪一下红色受击光，属正常现象
- [ ] 潜行状态下隔墙站在 12 格外 → 僵尸不会发现你；走近到 12 格内会被"嗅到"
- [ ] 站上 3 格高的柱子 → 僵尸垫方块爬上来；攀爬全程它不会走歪或自己走下塔（攀爬时原版走动被冻结）
- [ ] 隔沟搭路时 → 僵尸放一块走一步、笔直向你推进，不会被原版寻路带下桥
- [ ] 在空中横向搭路移动 → 僵尸爬塔追击时不再跳回地面，走出斜向阶梯跟着你走（坠落会被自动垫砖接住）；在开阔地它不会凭空乱垒浮空方块（仅贴着已有结构才续接）
- [ ] 你在低处、僵尸在高台上 → 它会横向逼近直到你正上方，才拆脚下方块跳下来，不会隔着两格就提前俯冲
- [ ] 隔空搭路快到你身边时 → 僵尸会把最后的间隙补满，不会停在一格之外发呆
- [ ] 隔一条 3 格宽的沟 → 僵尸朝你的方向逐格铺路过来（斜向时走折线）
- [ ] 绕自己挖一圈 1 格宽的壕沟 → 僵尸会把沟填平走过来
- [ ] 手持弓瞄准远处僵尸 → 僵尸左右蛇皮走位
- [ ] 一只僵尸发现你 → 40 格内所有僵尸（含隔墙的）同时锁定你并加速围攻
- [ ] 僵尸不会主动走进岩浆/仙人掌
- [ ] 僵尸持铁剑+盾牌；近身时以约 0.8 秒节奏挥砍（有横扫粒子与音效），一击约 3.5 颗心
- [ ] 举盾正对僵尸 → 攻击被格挡；但僵尸会环绕走位试图绕到侧后
- [ ] 绕到僵尸背后贴脸 → 它没转过身之前打不到你（准星射线判定，无杀戮光环）
- [ ] 疾跑逃离到 4~9 格 → 僵尸明显提速追击

## 架构总览

```
data/
  minecraft/tags/function/     # load/tick 挂接点（已完成，勿改）
  smartz/
    function/
      load.mcfunction          # 初始化记分板与默认配置
      tick.mcfunction          # 全局时钟 + 分频调度器（性能核心）
      init.mcfunction          # 新僵尸初始化：属性强化、开门、分配 id
      uninstall.mcfunction     # 卸载清理
      config/                  # 功能开关（每个开关一个文件）
      ai/
        core.mcfunction        # 每只僵尸的主循环（每 4gt 一次）
        sense.mcfunction       # 穿墙嗅探：微量伤害归因制造仇恨，32格索敌（潜行12格）
        stuck.mcfunction       # 追击受阻检测与分层决策（>=3 常规 / >=8 全试 / >=12 重置基线）
        climb_on.mcfunction    # 进入攀爬模式：冻结原版走动（-100%移速修饰符）
        climb_off.mcfunction   # 退出攀爬模式：到达高度/失去目标/建造关闭时解冻
        dig/decide.mcfunction  # 挖掘决策：选定要挖的方块
        dig/start.mcfunction   # 挖掘启动：marker 配对与时长设定（decide/down 共用）
        dig/down.mcfunction    # 天降打击：到玩家头顶后拆脚下方块坠落突袭
        dig/mine.mcfunction    # 分段挖掘执行（进度、粒子、音效、破坏）
        build/pillar.mcfunction# 垫方块爬高（tp 居中防滑落）
        build/bridge.mcfunction# 定向搭路：按目标方向网格步进铺路，可填壕沟
        build/catch.mcfunction # 坠落拦截：目标在上方时下坠自动垫砖，高度只增不减
        dodge.mcfunction       # 蛇皮走位闪避
        leap.mcfunction        # 近身跳劈
        hazard.mcfunction      # 危险方块规避
        swarm/alert.mcfunction # 发现玩家 → 咆哮 + 标记目标玩家并广播
        swarm/respond.mcfunction # 响应警报：加速围攻 + 目标传染（共享情报，不刷怪）
        pvp/main.mcfunction    # PVP 主逻辑：行为识别（持盾/疾跑逃离）+ 攻击节奏
        pvp/ray.mcfunction     # 准星射线：0.25格步进、被方块阻挡、点碰撞检测
        pvp/hit.mcfunction     # 命中结算：mob_attack 伤害归因僵尸，盾牌正面可挡
    tags/block/
      unbreakable.json         # 挖掘黑名单（基岩、黑曜石等）
      soft.json                # 软方块（挖得更快）
    predicate/
      aiming_player.json       # 检测持弓/弩的玩家
      sneaking.json            # 检测潜行中的玩家（嗅探降距用）
      sprinting.json           # 检测疾跑中的玩家（追击判定用）
```

## 记分板约定（所有模块共用）

| 记分板 | 用途 |
|---|---|
| `sz.clock` | 全局时钟（假人 `#tick` 持有当前刻数） |
| `sz.id` | 僵尸唯一编号（自增，用于分摊与走位方向） |
| `sz.config` | 配置项（假人 `#master` `#dig` `#build` `#swarm` `#dodge`，1=开 0=关） |
| `sz.posx` | 受阻检测用：该僵尸与目标的历史最近距离²（sz.posy/sz.posz 供临时假人使用） |
| `sz.stuck` | 连续无进展的检测周期数 |
| `sz.mine` | 挖掘进度倒计时（>0 表示正在挖） |
| `sz.cool` | 通用冷却（放方块/突进共用） |
| `sz.atk` | PVP 攻击冷却（0.8 秒攻击节奏） |

## 实体标签约定

| 标签 | 含义 |
|---|---|
| `sz.init` | 已完成初始化的僵尸 |
| `sz.alerted` | 已发现玩家、处于警报状态的僵尸 |
| `sz.mining` | 正在挖掘中的僵尸 |
| `sz.vip` | （玩家，瞬时）警报者的目标，用于向同伴传染仇恨 |
| `sz.climb` | 攀爬模式中的僵尸（原版走动被冻结，防走歪坠落） |
| `sz.pave` | 搭路惯性：连续步进中的僵尸（成功自打/失败自摘） |
| `sz.aim` | （玩家，瞬时）PVP 出手前的转身瞄准锚点 |

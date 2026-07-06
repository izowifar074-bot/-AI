# 智能僵尸 AI 数据包（Smart Zombie AI）

适用版本：**Minecraft Java 1.21.10**（`pack_format: 89`）

让所有僵尸拥有接近玩家的智能：隔墙索敌、挖方块破墙、搭桥过沟、垫方块爬高台、
群体围攻、蛇皮走位闪避弓箭、跳劈、规避岩浆等危险。

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
| `/function smartz:uninstall` | 完全卸载（清除记分板与标签） |

## 测试清单

- [ ] `/datapack list` 中数据包已启用，`/reload` 后出现加载消息
- [ ] 用墙把自己和僵尸隔开（32 格内）→ 数秒内僵尸隔墙锁定你并开始挖墙（有挖掘音效和粒子，方块分段破坏）。嗅探锁定的瞬间僵尸会闪一下红色受击光，属正常现象
- [ ] 潜行状态下隔墙站在 12 格外 → 僵尸不会发现你；走近到 12 格内会被"嗅到"
- [ ] 站上 3 格高的柱子 → 僵尸垫方块爬上来
- [ ] 隔一条 3 格宽的沟 → 僵尸搭桥过来
- [ ] 手持弓瞄准远处僵尸 → 僵尸左右蛇皮走位
- [ ] 一只僵尸发现你 → 附近僵尸集体加速围攻
- [ ] 僵尸不会主动走进岩浆/仙人掌

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
        stuck.mcfunction       # 追击受阻检测（距离不再缩小）→ 触发挖/搭/垫决策
        dig/decide.mcfunction  # 挖掘决策：选定要挖的方块
        dig/mine.mcfunction    # 分段挖掘执行（进度、粒子、音效、破坏）
        build/pillar.mcfunction# 垫方块爬高
        build/bridge.mcfunction# 搭桥过沟
        dodge.mcfunction       # 蛇皮走位闪避
        leap.mcfunction        # 近身跳劈
        hazard.mcfunction      # 危险方块规避
        swarm/alert.mcfunction # 发现玩家 → 广播警报
        swarm/respond.mcfunction # 响应警报：加速围攻 + 限量增援
    tags/block/
      unbreakable.json         # 挖掘黑名单（基岩、黑曜石等）
      soft.json                # 软方块（挖得更快）
    predicate/
      aiming_player.json       # 检测持弓/弩的玩家
      sneaking.json            # 检测潜行中的玩家（嗅探降距用）
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
| `sz.cool` | 通用冷却（放方块/跳劈/闪避共用或另分） |

## 实体标签约定

| 标签 | 含义 |
|---|---|
| `sz.init` | 已完成初始化的僵尸 |
| `sz.alerted` | 已发现玩家、处于警报状态的僵尸 |
| `sz.mining` | 正在挖掘中的僵尸 |

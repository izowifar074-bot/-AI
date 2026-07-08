# ============================================================
# smartz:load — 数据包加载时执行一次（由 minecraft:load 触发）
# 状态模型（共 10 个记分板，详见 README"状态模型"）：
#   sz.ai    尸壳受阻计数(@s) + 全部全局变量/常量/配置(#假人)
#   sz.id    尸壳唯一编号（挖掘 marker 配对同用）
#   sz.mine  挖掘进度倒计时        sz.cool  地形动作冷却
#   sz.atk   出手冷却（刻级）      sz.hurt  受击连招计数/格挡冷却(±)
#   sz.hp    上次采样血量×10       sz.pearl 珍珠(+起手/-冷却/0就绪)
#   sz.dmin  与目标历史最近距离²   sz.dprev 上一采样距离²
# ============================================================
scoreboard objectives add sz.ai dummy
scoreboard objectives add sz.id dummy
scoreboard objectives add sz.mine dummy
scoreboard objectives add sz.cool dummy
scoreboard objectives add sz.atk dummy
scoreboard objectives add sz.hurt dummy
scoreboard objectives add sz.hp dummy
scoreboard objectives add sz.pearl dummy
scoreboard objectives add sz.dmin dummy
scoreboard objectives add sz.dprev dummy
scoreboard players set #tick sz.ai 0
execute unless score #next_id sz.ai = #next_id sz.ai run scoreboard players set #next_id sz.ai 0
scoreboard players set #c2 sz.ai 2
scoreboard players set #c4 sz.ai 4
scoreboard players set #c8 sz.ai 8
scoreboard players set #c16 sz.ai 16
scoreboard players set #c20 sz.ai 20
scoreboard players set #cm1 sz.ai -1
execute unless score #master sz.ai = #master sz.ai run scoreboard players set #master sz.ai 1
execute unless score #dig sz.ai = #dig sz.ai run scoreboard players set #dig sz.ai 1
execute unless score #build sz.ai = #build sz.ai run scoreboard players set #build sz.ai 1
execute unless score #swarm sz.ai = #swarm sz.ai run scoreboard players set #swarm sz.ai 1
execute unless score #dodge sz.ai = #dodge sz.ai run scoreboard players set #dodge sz.ai 1
execute unless score #pvp sz.ai = #pvp sz.ai run scoreboard players set #pvp sz.ai 1
tellraw @a {"text":"[智能尸壳] 已加载。开关 /function smartz:toggle/<master|dig|build|swarm|dodge|pvp>；用 /tag <实体> add sz.enemy 可让尸壳仇恨该实体","color":"green"}

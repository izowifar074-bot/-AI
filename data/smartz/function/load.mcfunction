# ============================================================
# smartz:load — 数据包加载时执行一次（由 minecraft:load 触发）
# 职责：
#   1. 创建所有记分板：sz.clock sz.id sz.config sz.posx sz.posy sz.posz sz.stuck sz.mine sz.cool
#   2. 初始化全局假人分数：#tick sz.clock = 0；#next_id sz.id = 0
#   3. 设置默认配置（仅当未设置过时）：#master/#dig/#build/#swarm/#dodge sz.config = 1
#   4. 向聊天栏输出加载成功消息（tellraw @a）
# ============================================================
scoreboard objectives add sz.clock dummy
scoreboard objectives add sz.id dummy
scoreboard objectives add sz.config dummy
scoreboard objectives add sz.posx dummy
scoreboard objectives add sz.posy dummy
scoreboard objectives add sz.posz dummy
scoreboard objectives add sz.stuck dummy
scoreboard objectives add sz.mine dummy
scoreboard objectives add sz.cool dummy
scoreboard players set #tick sz.clock 0
scoreboard players set #next_id sz.id 0
scoreboard players set #c4 sz.clock 4
scoreboard players set #c8 sz.clock 8
scoreboard players set #c20 sz.clock 20
scoreboard players set #c16 sz.clock 16
scoreboard players set #cm1 sz.clock -1
execute unless score #master sz.config = #master sz.config run scoreboard players set #master sz.config 1
execute unless score #dig sz.config = #dig sz.config run scoreboard players set #dig sz.config 1
execute unless score #build sz.config = #build sz.config run scoreboard players set #build sz.config 1
execute unless score #swarm sz.config = #swarm sz.config run scoreboard players set #swarm sz.config 1
execute unless score #dodge sz.config = #dodge sz.config run scoreboard players set #dodge sz.config 1
tellraw @a {"text":"[智能僵尸] 已加载","color":"green"}
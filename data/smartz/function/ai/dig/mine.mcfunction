# ============================================================
# smartz:ai/dig/mine — 分段挖掘执行（executor = 尸壳，每 4gt 由 core 调用）
# 与自己 sz.id 配对的 marker 即挖掘目标：中断保护 → 进度递减 →
# 音效粒子 → 归零时 setblock air destroy（如玩家挖掘般掉落）。
# ============================================================
scoreboard players operation #mid sz.ai = @s sz.id
scoreboard players set #found sz.ai 0
execute as @e[type=minecraft:marker,tag=sz.target,distance=..8] if score @s sz.id = #mid sz.ai run scoreboard players set #found sz.ai 1
execute if score #found sz.ai matches 0 run scoreboard players set @s sz.mine 0
execute if score #found sz.ai matches 0 run tag @s remove sz.mining
execute if score #found sz.ai matches 0 run return 0
scoreboard players remove @s sz.mine 1
execute as @e[type=minecraft:marker,tag=sz.target,distance=..8] if score @s sz.id = #mid sz.ai at @s run playsound minecraft:block.stone.hit block @a ~ ~ ~ 1 1
execute as @e[type=minecraft:marker,tag=sz.target,distance=..8] if score @s sz.id = #mid sz.ai at @s run particle minecraft:block{block_state:"minecraft:stone"} ~0.5 ~0.5 ~0.5 0.25 0.25 0.25 0 8
execute if score @s sz.mine matches ..0 as @e[type=minecraft:marker,tag=sz.target,distance=..8] if score @s sz.id = #mid sz.ai at @s run setblock ~ ~ ~ air destroy
execute if score @s sz.mine matches ..0 as @e[type=minecraft:marker,tag=sz.target,distance=..8] if score @s sz.id = #mid sz.ai at @s run playsound minecraft:block.stone.break block @a ~ ~ ~ 1 1
execute if score @s sz.mine matches ..0 as @e[type=minecraft:marker,tag=sz.target,distance=..8] if score @s sz.id = #mid sz.ai run kill @s
execute if score @s sz.mine matches ..0 run tag @s remove sz.mining

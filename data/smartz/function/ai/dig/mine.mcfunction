# ============================================================
# smartz:ai/dig/mine — 分段挖掘执行（executor = 僵尸，每 4gt 由 core 调用）
# 职责：
#   1. sz.mine -= 1
#   2. 在配对 marker 处播放挖掘音效(block.stone.hit) + block 粒子（拟真挖掘感）
#   3. sz.mine 到 0 时：
#      - 在 marker 处 setblock air destroy（掉落物资，像玩家挖的一样）
#      - kill marker，移除 tag sz.mining
#   4. 中断保护：目标 marker 不存在 / 该处已变成空气 → 立即清状态 return
# ============================================================
scoreboard players operation #mid sz.id = @s sz.id
scoreboard players set #found sz.stuck 0
execute as @e[type=minecraft:marker,tag=sz.target,distance=..8] if score @s sz.id = #mid sz.id run scoreboard players set #found sz.stuck 1
execute if score #found sz.stuck matches 0 run scoreboard players set @s sz.mine 0
execute if score #found sz.stuck matches 0 run tag @s remove sz.mining
execute if score #found sz.stuck matches 0 run return 0
scoreboard players remove @s sz.mine 1
execute as @e[type=minecraft:marker,tag=sz.target,distance=..8] if score @s sz.id = #mid sz.id at @s run playsound minecraft:block.stone.hit block @a ~ ~ ~ 1 1
execute as @e[type=minecraft:marker,tag=sz.target,distance=..8] if score @s sz.id = #mid sz.id at @s run particle minecraft:block{block_state:"minecraft:stone"} ~0.5 ~0.5 ~0.5 0.25 0.25 0.25 0 8
execute if score @s sz.mine matches ..0 as @e[type=minecraft:marker,tag=sz.target,distance=..8] if score @s sz.id = #mid sz.id at @s run setblock ~ ~ ~ air destroy
execute if score @s sz.mine matches ..0 as @e[type=minecraft:marker,tag=sz.target,distance=..8] if score @s sz.id = #mid sz.id at @s run playsound minecraft:block.stone.break block @a ~ ~ ~ 1 1
execute if score @s sz.mine matches ..0 as @e[type=minecraft:marker,tag=sz.target,distance=..8] if score @s sz.id = #mid sz.id run kill @s
execute if score @s sz.mine matches ..0 run tag @s remove sz.mining
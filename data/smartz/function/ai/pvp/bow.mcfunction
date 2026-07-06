# ============================================================
# smartz:ai/pvp/bow — 弓箭射击（executor = 僵尸，位置 = 僵尸）
# 前置（main 已判定）：目标 9~32 格、弓冷却就绪、非珍珠起手期。
# 流程：
#   1. 视线检查（sight 射线）——看不见玩家绝不放箭
#   2. 预瞄点 = 目标胸口 + 重力补偿（按距离分层抬高）
#      + 水平提前量（目标速度 × 8 刻，宏 aim_lead）
#   3. 方向向量：眼位 marker 面向预瞄点前进 1 格，位移差 ×0.0016
#      即为 Motion（单位向量 × 1.6 骷髅箭速），宏 fire 发射
#   4. 箭 Owner 设为僵尸（不会射伤自己、正常记仇恨归因）
# ============================================================
tag @a remove sz.tgt
execute on target run tag @s add sz.tgt
execute unless entity @p[tag=sz.tgt] run return 0
# --- 视线检查 ---
scoreboard players set #los sz.stuck 0
scoreboard players set #sray sz.stuck 34
execute at @s anchored eyes facing entity @p[tag=sz.tgt] eyes positioned ^ ^ ^1 anchored feet run function smartz:ai/pvp/sight
execute if score #los sz.stuck matches 0 run tag @a remove sz.tgt
execute if score #los sz.stuck matches 0 run return 0
# --- 预瞄点：胸口基准 + 重力补偿分层 ---
execute at @p[tag=sz.tgt] run summon minecraft:marker ~ ~1.3 ~ {Tags:["sz.baim"]}
execute on target if entity @s[distance=9..14] as @e[type=minecraft:marker,tag=sz.baim,limit=1] at @s run tp @s ~ ~1.0 ~
execute on target if entity @s[distance=14..20] as @e[type=minecraft:marker,tag=sz.baim,limit=1] at @s run tp @s ~ ~2.6 ~
execute on target if entity @s[distance=20..26] as @e[type=minecraft:marker,tag=sz.baim,limit=1] at @s run tp @s ~ ~4.6 ~
execute on target if entity @s[distance=26..32] as @e[type=minecraft:marker,tag=sz.baim,limit=1] at @s run tp @s ~ ~7.0 ~
# --- 水平提前量：目标速度 × 8 刻 ---
execute on target store result score #lx sz.posx run data get entity @s Motion[0] 100
execute on target store result score #lz sz.posz run data get entity @s Motion[2] 100
execute store result storage smartz:tmp lx double 0.08 run scoreboard players get #lx sz.posx
execute store result storage smartz:tmp lz double 0.08 run scoreboard players get #lz sz.posz
execute as @e[type=minecraft:marker,tag=sz.baim,limit=1] at @s run function smartz:ai/pvp/aim_lead with storage smartz:tmp
# --- 方向向量：眼位 marker 面向预瞄点前进 1 格 ---
execute at @s anchored eyes positioned ^ ^ ^ run summon minecraft:marker ~ ~ ~ {Tags:["sz.bdir"]}
execute as @e[type=minecraft:marker,tag=sz.bdir,limit=1] store result score #ax sz.posx run data get entity @s Pos[0] 1000
execute as @e[type=minecraft:marker,tag=sz.bdir,limit=1] store result score #ay sz.posy run data get entity @s Pos[1] 1000
execute as @e[type=minecraft:marker,tag=sz.bdir,limit=1] store result score #az sz.posz run data get entity @s Pos[2] 1000
execute as @e[type=minecraft:marker,tag=sz.bdir,limit=1] at @s run tp @s ~ ~ ~ facing entity @e[type=minecraft:marker,tag=sz.baim,limit=1] feet
execute as @e[type=minecraft:marker,tag=sz.bdir,limit=1] at @s run tp @s ^ ^ ^1
execute as @e[type=minecraft:marker,tag=sz.bdir,limit=1] store result score #bx sz.posx run data get entity @s Pos[0] 1000
execute as @e[type=minecraft:marker,tag=sz.bdir,limit=1] store result score #by sz.posy run data get entity @s Pos[1] 1000
execute as @e[type=minecraft:marker,tag=sz.bdir,limit=1] store result score #bz sz.posz run data get entity @s Pos[2] 1000
scoreboard players operation #bx sz.posx -= #ax sz.posx
scoreboard players operation #by sz.posy -= #ay sz.posy
scoreboard players operation #bz sz.posz -= #az sz.posz
execute store result storage smartz:tmp mx double 0.0016 run scoreboard players get #bx sz.posx
execute store result storage smartz:tmp my double 0.0016 run scoreboard players get #by sz.posy
execute store result storage smartz:tmp mz double 0.0016 run scoreboard players get #bz sz.posz
# --- 发射 ---
execute at @e[type=minecraft:marker,tag=sz.bdir,limit=1] run function smartz:ai/pvp/fire with storage smartz:tmp
data modify entity @e[type=minecraft:arrow,tag=sz.arr,limit=1] Owner set from entity @s UUID
tag @e[type=minecraft:arrow,tag=sz.arr] remove sz.arr
playsound minecraft:entity.skeleton.shoot hostile @a ~ ~1.6 ~ 1 1
# --- 清理与冷却（10 × 4gt = 2 秒一箭）---
kill @e[type=minecraft:marker,tag=sz.baim]
kill @e[type=minecraft:marker,tag=sz.bdir]
tag @a remove sz.tgt
scoreboard players set @s sz.bcd 10

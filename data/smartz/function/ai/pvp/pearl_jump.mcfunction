# ============================================================
# smartz:ai/pvp/pearl_jump — 珍珠落点闪现（executor = 僵尸）
# 闪现到目标朝向自己一侧 2.5 格（沿脚部射线，落点贴地），
# 自受 5 点摔落伤害（与玩家扔珍珠代价一致）。完成后 sz.pearl
# 置 -600 进入 2 分钟冷却（main 每 4gt 恢复 1）。
# ============================================================
scoreboard players set #go sz.ai 0
execute on target run scoreboard players set #go sz.ai 1
execute if score #go sz.ai matches 0 run scoreboard players set @s sz.pearl -600
execute if score #go sz.ai matches 0 run item replace entity @s weapon.mainhand with minecraft:iron_sword
execute if score #go sz.ai matches 0 run return 0
tag @s add sz.tpme
particle minecraft:portal ~ ~1 ~ 0.3 0.8 0.3 0.5 40
execute on target at @s facing entity @e[type=minecraft:zombie,tag=sz.tpme,limit=1] feet positioned ^ ^ ^2.5 run tp @e[type=minecraft:zombie,tag=sz.tpme,limit=1] ~ ~ ~
execute at @s run playsound minecraft:entity.enderman.teleport hostile @a ~ ~ ~ 1 1
execute at @s run particle minecraft:portal ~ ~1 ~ 0.3 0.8 0.3 0.5 40
damage @s 5 minecraft:fall
item replace entity @s weapon.mainhand with minecraft:iron_sword
tag @s remove sz.tpme
scoreboard players set @s sz.pearl -600

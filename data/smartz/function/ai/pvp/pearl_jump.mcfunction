# ============================================================
# smartz:ai/pvp/pearl_jump — 珍珠落点闪现（executor = 僵尸）
# 闪现到"目标朝向自己一侧 2.5 格"处（不直接贴脸），
# 并像玩家扔珍珠一样自受 5 点摔落伤害。
# ============================================================
scoreboard players set @s sz.prl 0
scoreboard players set #go sz.stuck 0
execute on target run scoreboard players set #go sz.stuck 1
execute if score #go sz.stuck matches 0 run item replace entity @s weapon.mainhand with minecraft:iron_sword
execute if score #go sz.stuck matches 0 run return 0
tag @s add sz.tpme
particle minecraft:portal ~ ~1 ~ 0.3 0.8 0.3 0.5 40
execute on target at @s facing entity @e[type=minecraft:zombie,tag=sz.tpme,limit=1] feet positioned ^ ^ ^2.5 run tp @e[type=minecraft:zombie,tag=sz.tpme,limit=1] ~ ~ ~
execute at @s run playsound minecraft:entity.enderman.teleport hostile @a ~ ~ ~ 1 1
execute at @s run particle minecraft:portal ~ ~1 ~ 0.3 0.8 0.3 0.5 40
damage @s 5 minecraft:fall
item replace entity @s weapon.mainhand with minecraft:iron_sword
tag @s remove sz.tpme

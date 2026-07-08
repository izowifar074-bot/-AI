# ============================================================
# smartz:ai/pvp/hit — 命中结算（executor = 尸壳，位置 = 射线命中点）
# 对【当前目标】(tag=sz.aim) 结算 mob_attack 伤害并归因尸壳：
# 盾牌正面格挡/击退/护甲附魔全按原版。玩家与敌对生物通用。
# 无敌帧内 damage 失败 → 不播音效粒子（防音效机枪）。
# 冷却 1 刻（每 2gt 可再出手）；命中打断自己的挖掘状态。
# ============================================================
execute store success score #dmg sz.ai run damage @e[tag=sz.aim,dx=0,dy=0,dz=0,limit=1] 7 minecraft:mob_attack by @s
execute if score #dmg sz.ai matches 1 run particle minecraft:sweep_attack ~ ~ ~ 0 0 0 0 1
execute if score #dmg sz.ai matches 1 run playsound minecraft:entity.player.attack.sweep hostile @a ~ ~ ~ 1 0.8
scoreboard players set @s sz.atk 1
scoreboard players set @s sz.mine 0
tag @s remove sz.mining

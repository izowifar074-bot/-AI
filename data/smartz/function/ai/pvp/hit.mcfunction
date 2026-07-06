# ============================================================
# smartz:ai/pvp/hit — 命中结算（executor = 僵尸，位置 = 射线命中点）
# 伤害走原版 mob_attack 管线并归因于僵尸（by @s）：
#   - 玩家盾牌正面格挡完全有效（方向判定由原版处理）
#   - 击退方向、仇恨归因、伤害饰变（护甲/附魔）全部正常
# 命中后：0.8 秒攻击节奏 + 短暂收盾招架（抗性提升），并打断
# 自己的挖掘状态（近战优先于挖掘）。
# ============================================================
damage @a[dx=0,dy=0,dz=0,limit=1,gamemode=!creative,gamemode=!spectator] 7 minecraft:mob_attack by @s
particle minecraft:sweep_attack ~ ~ ~ 0 0 0 0 1
playsound minecraft:entity.player.attack.sweep hostile @a ~ ~ ~ 1 0.8
scoreboard players set @s sz.atk 4
effect give @s minecraft:resistance 1 1 true
scoreboard players set @s sz.mine 0
tag @s remove sz.mining

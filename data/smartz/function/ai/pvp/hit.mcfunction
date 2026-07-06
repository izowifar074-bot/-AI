# ============================================================
# smartz:ai/pvp/hit — 命中结算（executor = 僵尸，位置 = 射线命中点）
# 伤害走原版 mob_attack 管线并归因于僵尸（by @s）：
#   - 玩家盾牌正面格挡完全有效（方向判定由原版处理）
#   - 玩家受击无敌帧期间 damage 会失败 → 音效/粒子只在真正
#     造成伤害时播放，高频出手不会产生音效机枪
# 冷却 1 刻（下下刻即可再出手，配合无敌帧 = 引擎上限输出）。
# 命中打断自己的挖掘状态（近战优先于挖掘）。
# ============================================================
execute store success score #dmg sz.stuck run damage @a[dx=0,dy=0,dz=0,limit=1,gamemode=!creative,gamemode=!spectator] 7 minecraft:mob_attack by @s
execute if score #dmg sz.stuck matches 1 run particle minecraft:sweep_attack ~ ~ ~ 0 0 0 0 1
execute if score #dmg sz.stuck matches 1 run playsound minecraft:entity.player.attack.sweep hostile @a ~ ~ ~ 1 0.8
scoreboard players set @s sz.atk 1
scoreboard players set @s sz.mine 0
tag @s remove sz.mining

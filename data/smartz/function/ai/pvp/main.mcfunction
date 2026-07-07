# ============================================================
# smartz:ai/pvp/main — PVP 行为层（executor = 僵尸，每 4gt 由 core 调用）
# 出手与控距步法在 pvp/attack（每 1gt 由 tick 驱动），本函数负责：
#   1. 珍珠冷却推进；受击连招检测（被控立刻举盾 → guard）
#   2. 珍珠飞行倒计时 → pearl_jump 落点闪现
#   3. 行为识别：疾跑逃离 → 冲刺追击
#   4. 手持策略：搭路持圆石 / 其余持剑 / 起手持珍珠
#   5. 远程决策：16~48 格掷珍珠（2 分钟一次）
# （弓箭系统已按需求移除；近战环绕由 attack 的控距步法承担）
# ============================================================
execute if score @s sz.pcd matches 1.. run scoreboard players remove @s sz.pcd 1
# --- 被控举盾：血量下降 >=1.0 才算真受击 ---
# （不能用 HurtTime：嗅探/目标传染的 0.0001 归因伤同样会刷新它，
#   僵尸会被自家脉冲反复触发格挡，表现为莫名减速与呆滞）
execute store result score #hp sz.stuck run data get entity @s Health 10
execute unless score @s sz.hp = @s sz.hp run scoreboard players operation @s sz.hp = #hp sz.stuck
scoreboard players operation #hpd sz.stuck = @s sz.hp
scoreboard players operation #hpd sz.stuck -= #hp sz.stuck
scoreboard players operation @s sz.hp = #hp sz.stuck
execute if score #hpd sz.stuck matches 10.. if score @s sz.hurt matches 0.. run scoreboard players add @s sz.hurt 12
execute if score #hpd sz.stuck matches ..9 if score @s sz.hurt matches 1.. run scoreboard players remove @s sz.hurt 2
execute if score @s sz.hurt matches ..-1 run scoreboard players add @s sz.hurt 2
execute if score @s sz.hurt matches 20.. run function smartz:ai/pvp/guard
# --- 珍珠飞行倒计时 ---
execute if score @s sz.prl matches 2.. run scoreboard players remove @s sz.prl 1
execute if score @s sz.prl matches 1 run function smartz:ai/pvp/pearl_jump
# --- 有目标才继续 ---
scoreboard players set #go sz.stuck 0
execute on target run scoreboard players set #go sz.stuck 1
execute if score #go sz.stuck matches 0 run return 0
# --- 行为识别：疾跑逃离（4~9格）→ 冲刺追击 ---
scoreboard players set #run sz.stuck 0
execute on target if entity @s[distance=4..9,predicate=smartz:sprinting] run scoreboard players set #run sz.stuck 1
execute if score #run sz.stuck matches 1 run effect give @s minecraft:speed 2 2 true
# --- 手持策略（珍珠起手期跳过，手里握着珍珠）---
execute if score @s sz.prl matches 0 if entity @s[tag=sz.climb] unless items entity @s weapon.mainhand minecraft:cobblestone run item replace entity @s weapon.mainhand with minecraft:cobblestone
execute if score @s sz.prl matches 0 if entity @s[tag=sz.pave] unless items entity @s weapon.mainhand minecraft:cobblestone run item replace entity @s weapon.mainhand with minecraft:cobblestone
execute if score @s sz.prl matches 0 unless entity @s[tag=sz.climb] unless entity @s[tag=sz.pave] unless items entity @s weapon.mainhand minecraft:iron_sword run item replace entity @s weapon.mainhand with minecraft:iron_sword
# --- 末影珍珠：16~48 格且冷却就绪 ---
scoreboard players set #pok sz.stuck 0
execute if score @s sz.pcd matches 0 if score @s sz.prl matches 0 on target if entity @s[distance=16..48] run scoreboard players set #pok sz.stuck 1
execute if score #pok sz.stuck matches 1 run function smartz:ai/pvp/pearl_throw

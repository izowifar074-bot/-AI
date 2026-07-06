# ============================================================
# smartz:ai/pvp/main — PVP 行为层（executor = 僵尸，每 4gt 由 core 调用）
# 出手在 pvp/attack（每 1gt 由 tick 驱动），本函数负责：
#   1. 珍珠/弓冷却推进；受击连招检测（被控立刻举盾 → guard）
#   2. 珍珠飞行倒计时 → pearl_jump 落点闪现
#   3. 行为识别：疾跑逃离 → 冲刺追击；持盾 → 环绕走位
#   4. 手持策略：搭路持圆石 / 近战(≤8格)持剑 / 远程持弓 / 起手持珍珠
#   5. 远程决策：16~48 格掷珍珠（2 分钟一次）；9~32 格且有视线射箭
# ============================================================
execute if score @s sz.pcd matches 1.. run scoreboard players remove @s sz.pcd 1
execute if score @s sz.bcd matches 1.. run scoreboard players remove @s sz.bcd 1
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
scoreboard players set #near sz.stuck 0
execute on target if entity @s[distance=..8] run scoreboard players set #near sz.stuck 1
execute if score @s sz.prl matches 0 if entity @s[tag=sz.climb] unless items entity @s weapon.mainhand minecraft:cobblestone run item replace entity @s weapon.mainhand with minecraft:cobblestone
execute if score @s sz.prl matches 0 if entity @s[tag=sz.pave] unless items entity @s weapon.mainhand minecraft:cobblestone run item replace entity @s weapon.mainhand with minecraft:cobblestone
execute if score @s sz.prl matches 0 unless entity @s[tag=sz.climb] unless entity @s[tag=sz.pave] if score #near sz.stuck matches 1 unless items entity @s weapon.mainhand minecraft:iron_sword run item replace entity @s weapon.mainhand with minecraft:iron_sword
execute if score @s sz.prl matches 0 unless entity @s[tag=sz.climb] unless entity @s[tag=sz.pave] if score #near sz.stuck matches 0 unless items entity @s weapon.mainhand minecraft:bow run item replace entity @s weapon.mainhand with minecraft:bow
# --- 行为识别：目标持盾（主/副手）→ 环绕走位找侧后角度 ---
scoreboard players set #shield sz.stuck 0
execute on target if items entity @s weapon.offhand minecraft:shield run scoreboard players set #shield sz.stuck 1
execute on target if items entity @s weapon.mainhand minecraft:shield run scoreboard players set #shield sz.stuck 1
scoreboard players operation #par sz.clock = #tick sz.clock
scoreboard players operation #par sz.clock += @s sz.id
scoreboard players operation #par sz.clock %= #c16 sz.clock
execute if score #shield sz.stuck matches 1 if score #near sz.stuck matches 1 if score #par sz.clock matches 0..7 positioned ^0.9 ^ ^ if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ^0.9 ^ ^
execute if score #shield sz.stuck matches 1 if score #near sz.stuck matches 1 if score #par sz.clock matches 8..15 positioned ^-0.9 ^ ^ if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ^-0.9 ^ ^
# --- 末影珍珠：16~48 格且冷却就绪 ---
scoreboard players set #pok sz.stuck 0
execute if score @s sz.pcd matches 0 if score @s sz.prl matches 0 on target if entity @s[distance=16..48] run scoreboard players set #pok sz.stuck 1
execute if score #pok sz.stuck matches 1 run function smartz:ai/pvp/pearl_throw
# --- 弓箭：9~32 格、冷却就绪、非起手期（视线检查在 bow 内部）---
scoreboard players set #bok sz.stuck 0
execute if score @s sz.bcd matches 0 if score @s sz.prl matches 0 on target if entity @s[distance=9..32] run scoreboard players set #bok sz.stuck 1
execute if score #bok sz.stuck matches 1 run function smartz:ai/pvp/bow

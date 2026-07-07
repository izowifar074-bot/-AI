# ============================================================
# smartz:ai/pvp/main — PVP 行为层（executor = 僵尸，每 4gt 由 core 调用）
# 出手与控距步法在 pvp/attack（tick 每刻驱动）。本函数：
#   1. 珍珠状态机推进（sz.pearl：正=起手倒计时/负=冷却恢复/0=就绪）
#   2. 被控举盾：血量下降>=1.0 才算真受击（HurtTime 会被嗅探的
#      0.0001 归因伤刷新而误触发，故用血量差）；短窗两刀 → 格挡
#      （原 guard 内联：音效+抗性IV+停手1秒，sz.hurt=-30 为冷却）
#   3. 行为识别：疾跑逃离 → 冲刺追击
#   4. 手持策略：搭路持圆石/其余持剑/起手持珍珠
#   5. 16~48 格且珍珠就绪 → 掷出（原 pearl_throw 内联）
# ============================================================
execute if score @s sz.pearl matches ..-1 run scoreboard players add @s sz.pearl 1
execute if score @s sz.pearl matches 2.. run scoreboard players remove @s sz.pearl 1
execute if score @s sz.pearl matches 1 run function smartz:ai/pvp/pearl_jump
# --- 被控举盾 ---
execute store result score #hp sz.ai run data get entity @s Health 10
execute unless score @s sz.hp = @s sz.hp run scoreboard players operation @s sz.hp = #hp sz.ai
scoreboard players operation #hpd sz.ai = @s sz.hp
scoreboard players operation #hpd sz.ai -= #hp sz.ai
scoreboard players operation @s sz.hp = #hp sz.ai
execute if score #hpd sz.ai matches 10.. if score @s sz.hurt matches 0.. run scoreboard players add @s sz.hurt 12
execute if score #hpd sz.ai matches ..9 if score @s sz.hurt matches 1.. run scoreboard players remove @s sz.hurt 2
execute if score @s sz.hurt matches ..-1 run scoreboard players add @s sz.hurt 2
execute if score @s sz.hurt matches 20.. run playsound minecraft:item.shield.block hostile @a ~ ~1 ~ 1 1
execute if score @s sz.hurt matches 20.. run effect give @s minecraft:resistance 2 3 true
execute if score @s sz.hurt matches 20.. run scoreboard players set @s sz.atk 20
execute if score @s sz.hurt matches 20.. run scoreboard players set @s sz.hurt -30
# --- 有目标才继续 ---
scoreboard players set #go sz.ai 0
execute on target run scoreboard players set #go sz.ai 1
execute if score #go sz.ai matches 0 run return 0
# --- 疾跑逃离（4~9格）→ 冲刺追击 ---
scoreboard players set #run sz.ai 0
execute on target if entity @s[distance=4..9,predicate=smartz:sprinting] run scoreboard players set #run sz.ai 1
execute if score #run sz.ai matches 1 run effect give @s minecraft:speed 2 2 true
# --- 手持策略（珍珠起手期跳过）---
execute unless score @s sz.pearl matches 1.. if entity @s[tag=sz.climb] unless items entity @s weapon.mainhand minecraft:cobblestone run item replace entity @s weapon.mainhand with minecraft:cobblestone
execute unless score @s sz.pearl matches 1.. if entity @s[tag=sz.pave] unless items entity @s weapon.mainhand minecraft:cobblestone run item replace entity @s weapon.mainhand with minecraft:cobblestone
execute unless score @s sz.pearl matches 1.. unless entity @s[tag=sz.climb] unless entity @s[tag=sz.pave] unless items entity @s weapon.mainhand minecraft:iron_sword run item replace entity @s weapon.mainhand with minecraft:iron_sword
# --- 末影珍珠：16~48 格且就绪（原 pearl_throw 内联）---
scoreboard players set #pok sz.ai 0
execute if score @s sz.pearl matches 0 on target if entity @s[distance=16..48] run scoreboard players set #pok sz.ai 1
execute if score #pok sz.ai matches 1 run item replace entity @s weapon.mainhand with minecraft:ender_pearl
execute if score #pok sz.ai matches 1 run playsound minecraft:entity.ender_pearl.throw hostile @a ~ ~1.6 ~ 1 1
execute if score #pok sz.ai matches 1 run scoreboard players set @s sz.pearl 4

# ============================================================
# smartz:ai/core — 每只僵尸主循环（executor = 僵尸，每 4gt 一次）
#   0. #pvp → pvp/main（行为层；出手与步法在 pvp/attack，tick 每刻驱动）
#   0b. #build → build/catch（坠落拦截，攀爬不掉高度）
#   1. 挖掘中 → dig/mine 后 return
#   2. sz.cool 递减；攀爬模式每 4gt 驱动一次垫高（cool=1 限速）
#   3. #dodge → dodge（对弓走位；近战让位给控距步法）
#   4. 危险规避（无提前返回，直接内联）：脚前/前下有危险方块则后退
# ============================================================
execute if score #pvp sz.ai matches 1 run function smartz:ai/pvp/main
execute if score #build sz.ai matches 1 run function smartz:ai/build/catch
execute if score @s sz.mine matches 1.. run function smartz:ai/dig/mine
execute if score @s sz.mine matches 1.. run return 0
execute if score @s sz.cool matches 1.. run scoreboard players remove @s sz.cool 1
execute if entity @s[tag=sz.climb] if score #build sz.ai matches 1 run function smartz:ai/build/pillar
execute if score #dodge sz.ai matches 1 run function smartz:ai/dodge
scoreboard players set #haz sz.ai 0
execute positioned ^ ^ ^0.8 if block ~ ~ ~ #smartz:danger run scoreboard players set #haz sz.ai 1
execute positioned ^ ^ ^0.8 if block ~ ~-1 ~ #smartz:danger run scoreboard players set #haz sz.ai 1
execute if score #haz sz.ai matches 1 run tp @s ^ ^ ^-0.5

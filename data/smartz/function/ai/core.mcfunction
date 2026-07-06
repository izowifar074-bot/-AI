# ============================================================
# smartz:ai/core — 每只僵尸主循环（executor = 僵尸，每 4gt 一次）
# 职责（按顺序调用子模块，每步检查对应配置开关）：
#   0. #pvp 开启 → 执行 ai/pvp/main（近战优先，命中会打断挖掘）
#   0b. #build 开启 → 执行 ai/build/catch（坠落拦截，攀爬不掉高度）
#   1. 若 sz.mine > 0（正在挖掘）→ 执行 ai/dig/mine 后 return
#   2. 冷却分数 sz.cool > 0 则递减
#   2b. 攀爬模式（tag sz.climb）→ 每 4gt 驱动一次垫高（cool=1 限速）
#   3. #dodge 开启 → 执行 ai/dodge 与 ai/leap
#   4. 执行 ai/hazard（危险规避，始终开启）
# 注意：卡住检测(stuck)与警报(alert)由 tick 单独分频调度，不在此处
# ============================================================
execute if score #pvp sz.config matches 1 run function smartz:ai/pvp/main
execute if score #build sz.config matches 1 run function smartz:ai/build/catch
execute if score @s sz.mine matches 1.. run function smartz:ai/dig/mine
execute if score @s sz.mine matches 1.. run return 0
execute if score @s sz.cool matches 1.. run scoreboard players remove @s sz.cool 1
execute if entity @s[tag=sz.climb] if score #build sz.config matches 1 run function smartz:ai/build/pillar
execute if score #dodge sz.config matches 1 run function smartz:ai/dodge
execute if score #dodge sz.config matches 1 run function smartz:ai/leap
function smartz:ai/hazard

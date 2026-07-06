# ============================================================
# smartz:ai/climb_on — 进入攀爬模式（executor = 僵尸）
# 挂 -100% 移速修饰符冻结原版走动：攀爬期间原版寻路彻底失去
# 控制权，僵尸不会走歪、不会自己走下塔。垫高靠 tp，不受影响。
# 幂等：已在攀爬模式则不重复挂（modifier add 重复会报错）。
# ============================================================
execute unless entity @s[tag=sz.climb] run attribute @s minecraft:movement_speed modifier add smartz:freeze -1 add_multiplied_total
tag @s add sz.climb

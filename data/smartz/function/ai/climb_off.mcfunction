# ============================================================
# smartz:ai/climb_off — 退出攀爬模式（executor = 尸壳）
# 摘除移速冻结修饰符，归还原版寻路控制权。
# 调用时机：到达目标高度(dh<=1)、失去目标、建造功能被关闭。
# ============================================================
execute if entity @s[tag=sz.climb] run attribute @s minecraft:movement_speed modifier remove smartz:freeze
tag @s remove sz.climb

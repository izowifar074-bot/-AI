# ============================================================
# smartz:ai/rescue — 虚空自救（executor = 尸壳，每 4gt 由 core 调用）
# 触发：浮空 + 脚下 1~3 格皆空（深坠）+ 向下 20 格无安全落点（虚空
# 或危险）+ 冷却就绪。catch（贴结构攀爬拦截）不适用的开阔坠落场景。
# 方法（方形气球，纯位置步进无新实体）：以脚为中心，4 个基向同步
# 向外膨胀，逐格探测（feet 级撞墙 或 feet-1/-2/-3 有落点即命中）；
# 取最先撞墙的方向（切比雪夫最近），沿该方向在 feet-1 铺一条笔直
# 方块路径直达命中处，尸壳落桥走向生路。
# ============================================================
execute if score @s sz.cool matches 1.. run return 0
execute unless block ~ ~-1 ~ #minecraft:replaceable run return 0
execute unless block ~ ~-2 ~ #minecraft:replaceable run return 0
execute unless block ~ ~-3 ~ #minecraft:replaceable run return 0
# 深坠确认：脚下向下 20 格探到安全落点(#land=1)则不救，任其落地
scoreboard players set #land sz.ai 0
scoreboard players set #dropw sz.ai 20
execute positioned ~ ~-1 ~ run function smartz:ai/drop_probe
execute if score #land sz.ai matches 1 run return 0
# 气球外扩：4 基向各投一条外扩射线（半径上限 6），记录最近撞墙半径
scoreboard players set #rbest sz.ai 99
scoreboard players set #rdir sz.ai 0
scoreboard players set #rcur sz.ai 0
scoreboard players set #rstep sz.ai 0
execute rotated 0 0 run function smartz:ai/rescue_ray
scoreboard players set #rcur sz.ai 1
scoreboard players set #rstep sz.ai 0
execute rotated 90 0 run function smartz:ai/rescue_ray
scoreboard players set #rcur sz.ai 2
scoreboard players set #rstep sz.ai 0
execute rotated 180 0 run function smartz:ai/rescue_ray
scoreboard players set #rcur sz.ai 3
scoreboard players set #rstep sz.ai 0
execute rotated 270 0 run function smartz:ai/rescue_ray
# 命中(半径<=6) → 沿最近方向铺路（rescue_lay 用 #rbest 作剩余步数）
execute if score #rbest sz.ai matches ..6 if score #rdir sz.ai matches 0 align xyz rotated 0 0 run function smartz:ai/rescue_lay
execute if score #rbest sz.ai matches ..6 if score #rdir sz.ai matches 1 align xyz rotated 90 0 run function smartz:ai/rescue_lay
execute if score #rbest sz.ai matches ..6 if score #rdir sz.ai matches 2 align xyz rotated 180 0 run function smartz:ai/rescue_lay
execute if score #rbest sz.ai matches ..6 if score #rdir sz.ai matches 3 align xyz rotated 270 0 run function smartz:ai/rescue_lay
execute if score #rbest sz.ai matches ..6 run playsound minecraft:block.stone.place block @a ~ ~ ~ 1 0.9
execute if score #rbest sz.ai matches ..6 run scoreboard players set @s sz.cool 10

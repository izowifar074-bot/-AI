# ============================================================
# smartz:ai/stuck — 追击受阻检测与决策（executor = 尸壳，每 8gt 一次）
# 判定：与目标的距离²不再创新低 = 无进展（@s sz.dmin 为历史最低）。
# 豁免：目标明显拉远（速度差，@s sz.dprev 对比）；已入近战圈。
# 计数分层：>=2 常规决策 / >=8 升级档全试 / >=12 重置基线回落 6。
# 攀爬模式（tag sz.climb）：目标高 >=2 时冻结原版走动逐格垫高；
# 到达高度/失去目标/建造关闭/攀爬无效(计数>=6) 时解除。
# ============================================================
execute if score @s sz.mine matches 1.. run return 0
# 无目标 → 清态退出
scoreboard players set #go sz.ai 0
execute on target run scoreboard players set #go sz.ai 1
execute if score #go sz.ai matches 0 run function smartz:ai/climb_off
execute if score #go sz.ai matches 0 run tag @s remove sz.pave
execute if score #go sz.ai matches 0 run scoreboard players set @s sz.ai 0
execute if score #go sz.ai matches 0 run return 0
# 自身与目标整数坐标
execute store result score #zx sz.ai run data get entity @s Pos[0]
execute store result score #zy sz.ai run data get entity @s Pos[1]
execute store result score #zz sz.ai run data get entity @s Pos[2]
execute on target store result score #tx sz.ai run data get entity @s Pos[0]
execute on target store result score #ty sz.ai run data get entity @s Pos[1]
execute on target store result score #tz sz.ai run data get entity @s Pos[2]
# 高度差（带符号）与距离²
scoreboard players operation #dh sz.ai = #ty sz.ai
scoreboard players operation #dh sz.ai -= #zy sz.ai
scoreboard players operation #dx sz.ai = #tx sz.ai
scoreboard players operation #dx sz.ai -= #zx sz.ai
scoreboard players operation #dz sz.ai = #tz sz.ai
scoreboard players operation #dz sz.ai -= #zz sz.ai
scoreboard players operation #dy sz.ai = #dh sz.ai
scoreboard players operation #dx sz.ai *= #dx sz.ai
scoreboard players operation #dy sz.ai *= #dy sz.ai
scoreboard players operation #dz sz.ai *= #dz sz.ai
scoreboard players operation #dsq sz.ai = #dx sz.ai
scoreboard players operation #dsq sz.ai += #dy sz.ai
scoreboard players operation #dsq sz.ai += #dz sz.ai
scoreboard players operation #hsq sz.ai = #dx sz.ai
scoreboard players operation #hsq sz.ai += #dz sz.ai
# 近战圈豁免（3D 距离²<=8，近战射线可达）→ 交给 PVP，地形系统退出
execute if score #dsq sz.ai matches ..8 run function smartz:ai/climb_off
execute if score #dsq sz.ai matches ..8 run tag @s remove sz.pave
execute if score #dsq sz.ai matches ..8 run scoreboard players set @s sz.ai 0
execute if score #dsq sz.ai matches ..8 run return 0
# 远离豁免：目标在拉开距离 = 寻路正常只是追不上，不算受阻
scoreboard players operation #away sz.ai = #dsq sz.ai
scoreboard players operation #away sz.ai -= @s sz.dprev
scoreboard players operation @s sz.dprev = #dsq sz.ai
execute if score #away sz.ai matches 3.. run scoreboard players set @s sz.ai 0
execute if score #away sz.ai matches 3.. run return 0
# 进展判定：距离²创新低 → 清零计数并更新基线，否则计数+1
scoreboard players operation #delta sz.ai = @s sz.dmin
scoreboard players operation #delta sz.ai -= #dsq sz.ai
execute if score #delta sz.ai matches 1.. run scoreboard players set @s sz.ai 0
execute if score #delta sz.ai matches 1.. run scoreboard players operation @s sz.dmin = #dsq sz.ai
execute if score #delta sz.ai matches ..0 run scoreboard players add @s sz.ai 1
# 长期无进展 → 基线重置（防击退失真），回落 6 保持升级档循环
execute if score @s sz.ai matches 12.. run scoreboard players operation @s sz.dmin = #dsq sz.ai
execute if score @s sz.ai matches 12.. run scoreboard players set @s sz.ai 6
# 攀爬模式维护
execute if score #dh sz.ai matches ..1 run function smartz:ai/climb_off
execute if score #build sz.ai matches 0 run function smartz:ai/climb_off
# ---------- 决策 ----------
# #built=本轮已放方块（跳过挖掘防拆自家）；#jump=本轮已跳崖
scoreboard players set #built sz.ai 0
scoreboard players set #jump sz.ai 0
# 攀爬无效检测：冻结 2.4s 无进展 → 解冻还权；>=6 期间禁止再入冻
execute if entity @s[tag=sz.climb] if score @s sz.ai matches 6.. run function smartz:ai/climb_off
# 目标高 >=2 且受阻 → 入攀爬模式（原 climb_on 内联，无提前返回）
execute if score @s sz.ai matches 2..5 if score #dh sz.ai matches 2.. if score #build sz.ai matches 1 unless entity @s[tag=sz.climb] run attribute @s minecraft:movement_speed modifier add smartz:freeze -1 add_multiplied_total
execute if score @s sz.ai matches 2..5 if score #dh sz.ai matches 2.. if score #build sz.ai matches 1 run tag @s add sz.climb
# 攀爬模式：持续垫高（也由 core 每 4gt 驱动）
execute if entity @s[tag=sz.climb] if score #dh sz.ai matches 2.. if score #build sz.ai matches 1 run function smartz:ai/build/pillar
# 目标低 >=2：最优先跳崖下追（成功置 #jump=1，迂回路线全让位）
execute if score @s sz.ai matches 2.. if score #dh sz.ai matches ..-2 run function smartz:ai/descend
# 搭路惯性（tag sz.pave）：开搭后连续步进，不等计数器重新累积
execute if entity @s[tag=sz.pave] if score #dh sz.ai matches -1..1 if score #build sz.ai matches 1 run function smartz:ai/build/bridge
execute if entity @s[tag=sz.pave] if score #jump sz.ai matches 0 if score #dh sz.ai matches ..-2 if score #hsq sz.ai matches 2.. if score #build sz.ai matches 1 run function smartz:ai/build/bridge
# 同层受阻 → 定向搭路
execute if score @s sz.ai matches 2.. if score #dh sz.ai matches -1..1 if score #build sz.ai matches 1 run function smartz:ai/build/bridge
# 目标低 >=2 且无处可跳：未对齐 → 本层搭路逼近；已对齐 → 拆脚下天降
execute if score @s sz.ai matches 2.. if score #jump sz.ai matches 0 if score #dh sz.ai matches ..-2 if score #hsq sz.ai matches 2.. if score #build sz.ai matches 1 run function smartz:ai/build/bridge
execute if score @s sz.ai matches 2.. if score #jump sz.ai matches 0 if score #dh sz.ai matches ..-2 if score #hsq sz.ai matches ..1 if score #built sz.ai matches 0 if score #dig sz.ai matches 1 run function smartz:ai/dig/down
# 普通挖掘（目标不低于自己 1 格以上）
execute if score @s sz.ai matches 2.. if score #dh sz.ai matches -1.. if score #built sz.ai matches 0 if score #dig sz.ai matches 1 run function smartz:ai/dig/decide
# ---------- 升级档（>=8，约3秒仍无进展）：放宽路由全试 ----------
execute if score @s sz.ai matches 8.. if score #dh sz.ai matches 2.. if score #build sz.ai matches 1 run function smartz:ai/build/pillar
execute if score @s sz.ai matches 8.. if score #build sz.ai matches 1 run function smartz:ai/build/bridge
execute if score @s sz.ai matches 8.. if score #built sz.ai matches 0 if score #dig sz.ai matches 1 run function smartz:ai/dig/decide

# ============================================================
# smartz:ai/stuck — 追击受阻检测与决策（executor = 僵尸，每 8gt 一次）
# 判定标准：与攻击目标的距离²不再创新低 = 没有进展。
# @s sz.posx 存储该僵尸的历史最近距离²（init 时置为极大值）。
#
# 计数器 @s sz.stuck 只在真正取得进展或失去目标时清零，
# 决策本身不重置它（旧版决策后重置为 1，导致 12 阈值的基线
# 重置永远达不到，是死代码）。分层响应：
#   >=3  常规决策（按高度差路由：垫高/搭路/俯冲/挖掘）
#   >=8  顽固卡死升级：无视高度路由，能试的全试一遍
#   >=12 重置距离基线（防击退等造成基线失真），回落到 6 保持升级档
#
# 攀爬模式（tag sz.climb）：目标在上方>=2 且受阻时进入，冻结
# 原版走动（-100% 移速修饰符），每周期垫高一格；到达高度/失去
# 目标/建造关闭时解除。防止原版寻路把僵尸带歪、带下塔。
# ============================================================
execute if score @s sz.mine matches 1.. run return 0
# 无目标 → 解除攀爬冻结、清零退出
scoreboard players set #go sz.stuck 0
execute on target run scoreboard players set #go sz.stuck 1
execute if score #go sz.stuck matches 0 run function smartz:ai/climb_off
execute if score #go sz.stuck matches 0 run tag @s remove sz.pave
execute if score #go sz.stuck matches 0 run scoreboard players set @s sz.stuck 0
execute if score #go sz.stuck matches 0 run return 0
# 自身与目标的整数坐标
execute store result score #zx sz.posx run data get entity @s Pos[0]
execute store result score #zy sz.posy run data get entity @s Pos[1]
execute store result score #zz sz.posz run data get entity @s Pos[2]
execute on target store result score #tx sz.posx run data get entity @s Pos[0]
execute on target store result score #ty sz.posy run data get entity @s Pos[1]
execute on target store result score #tz sz.posz run data get entity @s Pos[2]
# 高度差（带符号，决策用）
scoreboard players operation #dh sz.posy = #ty sz.posy
scoreboard players operation #dh sz.posy -= #zy sz.posy
# 距离² = dx² + dy² + dz²
scoreboard players operation #dx sz.posx = #tx sz.posx
scoreboard players operation #dx sz.posx -= #zx sz.posx
scoreboard players operation #dz sz.posz = #tz sz.posz
scoreboard players operation #dz sz.posz -= #zz sz.posz
scoreboard players operation #dy sz.posy = #dh sz.posy
scoreboard players operation #dx sz.posx *= #dx sz.posx
scoreboard players operation #dy sz.posy *= #dy sz.posy
scoreboard players operation #dz sz.posz *= #dz sz.posz
scoreboard players operation #dsq sz.stuck = #dx sz.posx
scoreboard players operation #dsq sz.stuck += #dy sz.posy
scoreboard players operation #dsq sz.stuck += #dz sz.posz
# 水平距离²（供高空/俯冲决策使用）
scoreboard players operation #hsq sz.stuck = #dx sz.posx
scoreboard players operation #hsq sz.stuck += #dz sz.posz
# 已进入近战射程（3D 距离²<=8，约 2.8 格；近战射线可达 3.5 格）
# → 交给 PVP 层解决，地形系统退出。若无此豁免，贴身缠斗的僵尸
# 永远"无进展"，计数涨到升级档后会在平地上莫名垫高/起塔。
# （早前"隔一格干站"的真因是转身瞄准缺失，已修，豁免可安全恢复）
execute if score #dsq sz.stuck matches ..8 run function smartz:ai/climb_off
execute if score #dsq sz.stuck matches ..8 run tag @s remove sz.pave
execute if score #dsq sz.stuck matches ..8 run scoreboard players set @s sz.stuck 0
execute if score #dsq sz.stuck matches ..8 run return 0
# 与历史最近距离比较：变近 = 有进展
scoreboard players operation #delta sz.stuck = @s sz.posx
scoreboard players operation #delta sz.stuck -= #dsq sz.stuck
execute if score #delta sz.stuck matches 1.. run scoreboard players set @s sz.stuck 0
execute if score #delta sz.stuck matches 1.. run scoreboard players operation @s sz.posx = #dsq sz.stuck
execute if score #delta sz.stuck matches ..0 run scoreboard players add @s sz.stuck 1
# 长期无进展 → 基线重置（防击退失真），回落到 6 保持升级档循环
execute if score @s sz.stuck matches 12.. run scoreboard players operation @s sz.posx = #dsq sz.stuck
execute if score @s sz.stuck matches 12.. run scoreboard players set @s sz.stuck 6
# 攀爬模式维护：到达目标高度或建造被关闭 → 解冻还权给原版寻路
execute if score #dh sz.posy matches ..1 run function smartz:ai/climb_off
execute if score #build sz.config matches 0 run function smartz:ai/climb_off
# ---------- 决策 ----------
# #built 标记本轮是否已放置方块，放了就不再触发挖掘，
# 防止转头啃掉自己刚放的方块。触发阈值 2（约0.8秒反应）。
scoreboard players set #built sz.stuck 0
# 目标在上方>=2 且受阻 → 进入攀爬模式
execute if score @s sz.stuck matches 2.. if score #dh sz.posy matches 2.. if score #build sz.config matches 1 run function smartz:ai/climb_on
# 攀爬模式：持续垫高（也由 core 每 4gt 驱动，见 core.mcfunction）
execute if entity @s[tag=sz.climb] if score #dh sz.posy matches 2.. if score #build sz.config matches 1 run function smartz:ai/build/pillar
# 搭路惯性（tag sz.pave，bridge 成功时自打/失败时自摘）：
# 一旦开搭，只要路线成立就连续步进，不再等计数器重新累积——
# 否则每步的进展都会清零计数器，导致每块间隔 1 秒以上，观感极慢
execute if entity @s[tag=sz.pave] if score #dh sz.posy matches -1..1 if score #build sz.config matches 1 run function smartz:ai/build/bridge
execute if entity @s[tag=sz.pave] if score #dh sz.posy matches ..-2 if score #hsq sz.stuck matches 2.. if score #build sz.config matches 1 run function smartz:ai/build/bridge
# 同层受阻 → 定向搭路
execute if score @s sz.stuck matches 2.. if score #dh sz.posy matches -1..1 if score #build sz.config matches 1 run function smartz:ai/build/bridge
# 目标在下方>=2：未到正上方 → 横向搭路逼近；已到正上方 → 天降
execute if score @s sz.stuck matches 2.. if score #dh sz.posy matches ..-2 if score #hsq sz.stuck matches 2.. if score #build sz.config matches 1 run function smartz:ai/build/bridge
execute if score @s sz.stuck matches 2.. if score #dh sz.posy matches ..-2 if score #hsq sz.stuck matches ..1 if score #built sz.stuck matches 0 if score #dig sz.config matches 1 run function smartz:ai/dig/down
# 普通挖掘（目标不低于自己 1 格以上时）
execute if score @s sz.stuck matches 2.. if score #dh sz.posy matches -1.. if score #built sz.stuck matches 0 if score #dig sz.config matches 1 run function smartz:ai/dig/decide
# ---------- 顽固卡死升级（约3秒仍无进展）：放宽路由全试 ----------
# 垫高仍要求目标在上方（dh>=1）——目标不在上方时垫高毫无意义，
# 只会在平地凭空起塔
execute if score @s sz.stuck matches 8.. if score #dh sz.posy matches 1.. if score #build sz.config matches 1 run function smartz:ai/build/pillar
execute if score @s sz.stuck matches 8.. if score #build sz.config matches 1 run function smartz:ai/build/bridge
execute if score @s sz.stuck matches 8.. if score #built sz.stuck matches 0 if score #dig sz.config matches 1 run function smartz:ai/dig/decide

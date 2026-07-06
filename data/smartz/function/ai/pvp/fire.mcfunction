# ============================================================
# smartz:ai/pvp/fire — 发射箭（宏函数，executor = 僵尸，位置 = 方向点）
# 由 bow 以 with storage smartz:tmp 调用：mx/my/mz = 单位方向 × 1.6
# （骷髅箭速）。生成点在眼前 1 格的方向 marker 处，避开自身碰撞箱。
# ============================================================
$summon minecraft:arrow ~ ~ ~ {Motion:[$(mx),$(my),$(mz)],damage:6.0d,pickup:0b,crit:1b,Tags:["sz.arr"]}

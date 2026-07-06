# ============================================================
# smartz:ai/dig/down — 天降打击（executor = 僵尸，由 stuck 触发）
# 前置（stuck 已判定）：目标在自己下方 >= 2 格且水平距离 <= 2，
# 即已站到玩家头顶附近。拆掉自己脚下的方块，坠落突袭；落地后
# PVP 模块自然接管近战。
# ============================================================
execute align xyz positioned ~ ~-1 ~ unless block ~ ~ ~ #minecraft:replaceable unless block ~ ~ ~ minecraft:water unless block ~ ~ ~ minecraft:lava unless block ~ ~ ~ #smartz:unbreakable run summon minecraft:marker ~ ~ ~ {Tags:["sz.target","sz.new"]}
function smartz:ai/dig/start

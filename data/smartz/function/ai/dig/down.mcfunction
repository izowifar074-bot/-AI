# ============================================================
# smartz:ai/dig/down — 天降打击（executor = 僵尸，由 stuck 触发）
# 兜底手段：仅当 descend 找不到任何可跳的开放落沿（站在封闭
# 天花板/全封闭平台上）且已到玩家头顶附近时触发。
# 拆掉自己脚下的方块，坠落突袭；落地后 PVP 模块自然接管近战。
# ============================================================
execute align xyz positioned ~ ~-1 ~ unless block ~ ~ ~ #minecraft:replaceable unless block ~ ~ ~ minecraft:water unless block ~ ~ ~ minecraft:lava unless block ~ ~ ~ #smartz:unbreakable run summon minecraft:marker ~ ~ ~ {Tags:["sz.target","sz.new"]}
function smartz:ai/dig/start

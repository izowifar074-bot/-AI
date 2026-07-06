# ============================================================
# smartz:ai/swarm/respond — 响应警报（executor = 被召集的僵尸）
# 职责：
#   1. 获得速度 II 5 秒（effect give，hideParticles=true）
#      follow_range 已在 init 拉到 64，会自然索敌加入围攻
#   2. 限量增援：仅当 32 格内僵尸数 < 8 时，小概率（random 或 clock 取模）
#      在警报僵尸附近 summon 1 只新僵尸（新僵尸会被 tick 自动初始化）
#   3. 增援要有冷却控制，严禁无限刷怪
# ============================================================
effect give @s minecraft:speed 5 1 true
# ============================================================
# smartz:ai/pvp/pearl_throw — 掷出末影珍珠（executor = 僵尸）
# 前置（main 已判定）：目标 16~48 格、珍珠冷却就绪。
# 原版珍珠不会传送生物（仅玩家生效），故模拟：切手持珍珠 +
# 掷出音效，sz.prl 倒计时模拟飞行（约0.6秒），到时由
# pearl_jump 完成落点闪现。冷却 2 分钟（600 × 4gt = 2400gt）。
# ============================================================
item replace entity @s weapon.mainhand with minecraft:ender_pearl
playsound minecraft:entity.ender_pearl.throw hostile @a ~ ~1.6 ~ 1 1
scoreboard players set @s sz.prl 4
scoreboard players set @s sz.pcd 600

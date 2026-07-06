# ============================================================
# smartz:ai/pvp/guard — 被控举盾（executor = 僵尸）
# 触发（由 main 的受击窗口检测）：短时间内受击两次 = 正在被连招。
# 立即格挡：盾格音效 + 抗性提升IV 2秒（8成减伤）+ 缓速（举盾走不快）
# + 1 秒内不出手（收剑举盾）。sz.hurt 置 -30 作为格挡冷却
# （每 4gt 回 2，约 3 秒后才能再次格挡，防止无限龟盾）。
# ============================================================
scoreboard players set @s sz.hurt -30
playsound minecraft:item.shield.block hostile @a ~ ~1 ~ 1 1
effect give @s minecraft:resistance 2 3 true
effect give @s minecraft:slowness 2 2 true
scoreboard players set @s sz.atk 20

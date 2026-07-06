# ============================================================
# smartz:ai/dig/mine — 分段挖掘执行（executor = 僵尸，每 4gt 由 core 调用）
# 职责：
#   1. sz.mine -= 1
#   2. 在配对 marker 处播放挖掘音效(block.stone.hit) + block 粒子（拟真挖掘感）
#   3. sz.mine 到 0 时：
#      - 在 marker 处 setblock air destroy（掉落物资，像玩家挖的一样）
#      - kill marker，移除 tag sz.mining
#   4. 中断保护：目标 marker 不存在 / 该处已变成空气 → 立即清状态 return
# ============================================================

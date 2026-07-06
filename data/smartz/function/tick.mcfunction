# ============================================================
# smartz:tick — 每游戏刻执行（由 minecraft:tick 触发）
# 职责（性能核心，分频调度）：
#   1. #tick sz.clock += 1
#   2. 若总开关 #master sz.config = 0 则直接 return
#   3. 对未初始化僵尸执行 init（每刻都查，选择器带 tag=!sz.init 限制）
#   4. 每 4gt：对玩家 48 格内的已初始化僵尸执行 ai/core
#   5. 每 8gt：执行 ai/stuck（卡住检测）
#   6. 每 20gt：执行 ai/swarm/alert（警报广播）
#   分频用 scoreboard players operation 取模实现
# ============================================================

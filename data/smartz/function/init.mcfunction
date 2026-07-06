# ============================================================
# smartz:init — 以每只【新僵尸】身份执行一次（executor = 该僵尸）
# 职责：
#   1. 属性强化（attribute 命令）：
#      - follow_range = 64（隔墙远距离索敌）
#      - movement_speed = 0.28（略快于玩家步行）
#      - knockback_resistance = 0.3
#      - step_height = 1.0（自动走上 1 格台阶）
#      - spawn_reinforcements = 0.35
#   2. data merge 开启 CanBreakDoors
#   3. 分配唯一编号：从 #next_id sz.id 取值并自增
#   4. 打上 tag sz.init 防止重复初始化
# ============================================================

# ============================================================
# smartz:ai/stuck — 卡住检测（executor = 僵尸，每 8gt 一次）
# 这是"挖/搭/垫"三大地形交互的唯一触发器
# 职责：
#   1. 用 execute store 将当前方块坐标存入临时分数，与 sz.posx/y/z 比较
#   2. 相同 → sz.stuck += 1；不同 → sz.stuck = 0 并更新 sz.posx/y/z
#   3. 当 sz.stuck >= 5（约2秒未动）且有攻击目标(execute on target)
#      且与目标距离 > 2 格时，进入决策：
#      - 目标在上方 >= 2 格 且 #build 开 → ai/build/pillar
#      - 前方(视线方向1格)是实体方块 且 #dig 开 → ai/dig/decide
#      - 前方悬空(前下方是空气) 且 #build 开 → ai/build/bridge
#   4. 触发任一行为后 sz.stuck 归零
# ============================================================

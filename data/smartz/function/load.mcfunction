# ============================================================
# smartz:load — 数据包加载时执行一次（由 minecraft:load 触发）
# 职责：
#   1. 创建所有记分板：sz.clock sz.id sz.config sz.posx sz.posy sz.posz sz.stuck sz.mine sz.cool
#   2. 初始化全局假人分数：#tick sz.clock = 0；#next_id sz.id = 0
#   3. 设置默认配置（仅当未设置过时）：#master/#dig/#build/#swarm/#dodge sz.config = 1
#   4. 向聊天栏输出加载成功消息（tellraw @a）
# ============================================================

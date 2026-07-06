# ============================================================
# smartz:ai/dig/decide — 挖掘决策（executor = 僵尸，由 stuck 触发）
# 职责：
#   1. 以眼睛为锚点，检查视线正前方 1 格（anchored eyes positioned ^ ^ ^1）
#      - 若为 #smartz:unbreakable 中的方块 → 放弃，return
#      - 若为可破坏实体方块 → 选定为挖掘目标
#   2. 若眼前是空气，检查脚前 1 格（腿部高度），同样规则选定
#   3. 目标在正上方时检查头顶 1 格；正下方 >= 3 格时检查脚下 1 格
#   4. 选定后：
#      - 打 tag sz.mining
#      - sz.mine 设为倒计时初值：#smartz:soft 中的方块 = 5（约1秒），否则 10（约2秒）
#      - 把目标方块相对方位记录下来（推荐：在目标方块处 summon marker 并打专属 tag，
#        marker 与僵尸用相同 sz.id 分数配对，避免僵尸转头后挖错方块）
# ============================================================
execute anchored eyes positioned ^ ^ ^1 align xyz unless block ~ ~ ~ minecraft:air unless block ~ ~ ~ minecraft:cave_air unless block ~ ~ ~ minecraft:water unless block ~ ~ ~ minecraft:lava unless block ~ ~ ~ #smartz:unbreakable run summon minecraft:marker ~ ~ ~ {Tags:["sz.target","sz.new"]}
execute anchored eyes positioned ^ ^ ^1 align xyz if block ~ ~ ~ minecraft:air positioned ~ ~-1 ~ unless block ~ ~ ~ minecraft:air unless block ~ ~ ~ minecraft:cave_air unless block ~ ~ ~ minecraft:water unless block ~ ~ ~ minecraft:lava unless block ~ ~ ~ #smartz:unbreakable run summon minecraft:marker ~ ~ ~ {Tags:["sz.target","sz.new"]}
execute if entity @e[type=minecraft:marker,tag=sz.new] run scoreboard players operation @e[type=minecraft:marker,tag=sz.new,limit=1] sz.id = @s sz.id
execute if entity @e[type=minecraft:marker,tag=sz.new] run tag @s add sz.mining
execute if entity @e[type=minecraft:marker,tag=sz.new] run scoreboard players set @s sz.mine 10
execute if entity @e[type=minecraft:marker,tag=sz.new] at @e[type=minecraft:marker,tag=sz.new,limit=1] if block ~ ~ ~ #smartz:soft run scoreboard players set @s sz.mine 5
execute if entity @e[type=minecraft:marker,tag=sz.new] run tag @e[type=minecraft:marker,tag=sz.new] remove sz.new
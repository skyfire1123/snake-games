# 🍎 食物系统设计修订方案

> **基于PM反馈**: "一次只出现一个食物让我吃"  
> **日期**: 2026-03-24  
> **状态**: 待评审

---

## 一、问题陈述

### 当前设计缺陷
- **单食物模式**: 屏幕上同时只有1个食物，吃掉才刷新下一个
- **体验问题**: 蛇移动速度>食物刷新速度时，出现大量"空跑"时间（蛇在无食物的格子上移动）
- **无聊感**: 玩家在等待下一个食物生成时没有事情可做，节奏单调
- **策略性缺失**: 不存在风险/回报取舍，所有食物等效

### PM原话
> "一次只出现一个食物让我吃"

### 影响范围
- 主要影响: Classic模式体验
- 次要影响: Challenge模式（计时压力下，空跑更致命）
- 无尽模式相对影响较小（但也可受益于多食物系统）

---

## 二、修订方案概述

### 核心思路
**"蓄力池"模式** — 改为维护一个 **3-5个食物同时存在** 的动态池，替代原先的"吃完一个才刷新一个"逻辑。

- 蛇吃掉任意食物 → 立即从池中移除 → 补充1个新食物至最低阈值
- Level N 的总食物量 **不变** (`_food_count = 10 + N * 5`)，只是分配方式改变
- 4种食物类型按权重随机生成，替代单一Normal类型

### 新系统优势
| 维度 | 旧系统 | 新系统 |
|------|--------|--------|
| 同时可见食物数 | 1 | 3-5 |
| 空跑时间 | 高（尤其高速关卡） | 低（蛇总能找到近的食物） |
| 策略深度 | 无 | 风险/回报选择 |
| 视觉丰富度 | 低 | 高（多颜色动画并存） |
| 实现复杂度 | 低 | 中等（需FoodManager） |

---

## 三、新食物类型详解

### 食物类型表

| 类型 | 颜色/外观 | 分数 | 生命周期 | 特殊效果 | 生成权重 |
|------|-----------|------|----------|----------|----------|
| **普通食物** | 红色霓虹圆形 | +10 | 永久（被吃才消失） | 无 | 55% |
| **金币食物** | 金色旋转星形 | +25 | 8秒后消失 | 无 | 25% |
| **能量食物** | 蓝色闪烁菱形 | +15 | 6秒后消失 | 吃后3秒内蛇移动速度×0.7（更慢但更安全） | 12% |
| **炸弹食物** | 白色快速闪烁方块 | +5 | 4秒后消失 | 无（只是分少） | 8% |

> **注意**: 炸弹食物（Timed）分少但存在时间短，迫使玩家快速决策，风险/回报明显。

### 各类型视觉效果（已有Sprite）
- `food_normal.png` — 红色霓虹圆形，脉冲发光动画（每0.5s）
- `food_special_gold.png` — 金色星形，360°旋转（2s一圈），持续8秒
- `food_special_blue.png` — 蓝色菱形，快速闪烁（0.3s周期），持续6秒
- `food_timed.png` — 白色方块+红色边框，极快闪烁（0.2s），持续4秒

---

## 四、模式差异设计

### Classic模式
- **总食物量**: `10 + Level * 5`（不变）
- **同时可见数**: 3-5个（随Level略微增加）
  - Level 1-3: 固定3个
  - Level 4-6: 固定4个
  - Level 7+: 固定5个
- **过关条件**: 累计吃掉全部指定数量食物 → 显示"LEVEL CLEAR" → 重置蛇、生成下一关食物池
- **速度递进**: 不变，`interval = base_interval / speed_multiplier`

### Endless模式
- **同时可见数**: 固定3个
- **无过关概念**: 永久吃食物，得分累积
- **分数构成**: `Normal×10 + Gold×25 + Energy×15 + Bomb×5`

### Challenge模式（TIME_LIMIT / STEP_LIMIT）
- **同时可见数**: 4个（比Classic多1个，降低时间压力）
- **炸弹食物权重提高**: 炸弹从8%→15%，增加紧迫感
- **时间/步数耗尽**: game over（不变）

---

## 五、实现方案

### 架构变更：引入FoodManager

```
旧架构:
main.gd ──(信号)──> Food (单个Area2D)
新架构:
main.gd ──> FoodManager (管理多个Food节点)
                ├── Food Pool: 3-5个活跃Food节点
                ├── _active_foods: Array[Food]
                └── _min_foods / _max_foods
```

### 核心逻辑

```gdscript
# FoodManager.gd (新建)
extends Node2D

var _active_foods: Array[Area2D] = []
var _food_scene: PackedScene = preload("res://scripts/food.gd")
var _min_foods: int = 3
var _max_foods: int = 5
var _occupied_cells: Array[Vector2i] = []

signal food_eaten_by_type(food_type: int, position: Vector2i)

func _ready() -> void:
    pass

func initialize(min_foods: int, max_foods: int) -> void:
    _min_foods = min_foods
    _max_foods = max_foods
    # 清空现有食物
    for food in _active_foods:
        if is_instance_valid(food):
            food.queue_free()
    _active_foods.clear()

func set_occupied_cells(cells: Array[Vector2i]) -> void:
    _occupied_cells = cells

func spawn_initial_pool(total_food_count: int) -> void:
    # Classic模式: 生成固定数量的食物（用于计数）
    # 每个食物被吃后不再补充，直到下一关重置
    # 但同时存在3-5个，所以"活跃食物数"≠"总食物数"
    # 
    # 实现: 每个食物记录是否"已被吃"
    # 活跃池始终维持3-5个，总消耗达到total后停止补充
    pass

func spawn_one_food() -> void:
    # 1. 从权重池随机选择食物类型
    # 2. 在空格子中随机选位置
    # 3. 实例化food.gd并加入_active_foods
    # 4. 连接food_eaten信号
    pass

func on_food_eaten(food: Area2D) -> void:
    # 1. 从_active_foods移除
    # 2. 播放粒子+音效
    # 3. 通知main.gd分数更新
    # 4. 若在"补充模式"下（未达到总食物量），spawn_one_food
    pass

func get_active_count() -> int:
    return _active_foods.size()

func get_all_positions() -> Array[Vector2i]:
    return _active_foods.map(func(f): return f.get_grid_position())
```

### 关键设计决策

#### 1. Classic模式的"总食物量"如何处理？
**方案**: 沿用 `_food_remaining` 计数器
- 每关开始: `_food_remaining = 10 + Level * 5`
- 每次吃食物: `_food_remaining -= 1`
- 活跃池始终维持3-5个，直到 `_food_remaining == 0` 时停止补充
- 剩余食物被吃光后 → 过关

#### 2. Endless模式的无限食物如何处理？
**方案**: 永远不停止补充，`_min_foods` 就是永久维持量

#### 3. 食物消失（Timed/Bomb）的超时处理
```gdscript
# food.gd 新增
var _lifetime: float = -1.0  # -1 = 永久
var _lifetime_timer: Timer

func set_lifetime(seconds: float) -> void:
    _lifetime = seconds
    _lifetime_timer = Timer.new()
    _lifetime_timer.wait_time = seconds
    _lifetime_timer.one_shot = true
    _lifetime_timer.timeout.connect(_on_lifetime_expired)
    add_child(_lifetime_timer)
    _lifetime_timer.start()

func _on_lifetime_expired() -> void:
    # 从FoodManager移除（不发分数，不播吃音效）
    # 播放短暂消失动画（缩小+淡出，0.2s）
    food_expired.emit(self)  # → FoodManager处理
```

#### 4. 位置冲突
- 多个食物不能在同一格
- `spawn()` 时传入 `_occupied_cells`（蛇身+其他食物位置）

---

## 六、分数公式更新

### 单关得分（Classic）
```
Level N 总分 = Σ(普通食物 × 10) + Σ(金币食物 × 25) + Σ(能量食物 × 15) + Σ(炸弹食物 × 5) + 通关奖励(N × 50)
```

### 无尽模式
```
总局分 = Σ(普通食物 × 10) + Σ(金币食物 × 25) + Σ(能量食物 × 15) + Σ(炸弹食物 × 5)
```

### 期望值分析（Classic Level 5，关卡总食物30个）
| 食物类型 | 权重 | 期望个数 | 单个分 | 小计期望 |
|----------|------|----------|--------|----------|
| 普通 | 55% | ~16.5 | 10 | 165 |
| 金币 | 25% | ~7.5 | 25 | 187.5 |
| 能量 | 12% | ~3.6 | 15 | 54 |
| 炸弹 | 8% | ~2.4 | 5 | 12 |
| **小计** | | **30** | | **~418.5** |
| 通关奖励 | | | | +250 (Level 5×50) |
| **总计** | | | | **~668.5** |

对比旧系统（30普通×10 + 250奖励 = 550），新系统期望分提高约22%，体现策略价值。

---

## 七、实现任务拆解

| 任务 | 负责人 | 工时估计 | 优先级 |
|------|--------|----------|--------|
| 新建 FoodManager.gd（管理食物池） | Coder | 2h | P0 |
| 重构 main.gd 与 FoodManager 通信 | Coder | 1h | P0 |
| 为4种食物类型实现权重随机选择 | Coder | 1h | P0 |
| 实现Timed食物超时消失逻辑 | Coder | 1h | P0 |
| 实现Blue食物的"减速吃"效果 | Coder | 1.5h | P1 |
| 更新分数公式（HUD显示） | Coder | 0.5h | P0 |
| 调整Classic/Endless/Challenge模式差异 | Coder | 1h | P0 |
| 验收测试（多食物碰撞、过关逻辑） | Coder | 1h | P1 |
| 更新GDD文档 | PM | 0.5h | P1 |

**预计总工时**: ~9.5h（Coder）+ 0.5h（PM文档）

---

## 八、向后兼容性

- **API兼容**: `food.gd` 的 `spawn()` 接口不变，新增 `set_lifetime()` 可选调用
- **模式兼容**: 3种模式接口不变，仅内部逻辑调整
- **破坏性变更**: 无（仅扩展，非替换）
- **测试注意**: 需覆盖"快速连续吃两个食物"场景（确保FoodManager正确处理）

---

## 九、风险与缓解

| 风险 | 影响 | 缓解方案 |
|------|------|----------|
| 食物重叠生成 | 显示异常 | spawn前双重检查 `_occupied_cells + _active_food_positions` |
| 高速关卡食物来不及吃就消失 | 玩家受挫感 | Level 1-5的Timed/Bomb食物寿命+2s缓冲 |
| Blue减速效果导致蛇撞墙 | 惩罚性过强 | 减速效果限定为"无敌3秒"（暂时穿墙或减速更保守×0.8） |
| 食物数量过多干扰操作 | 视觉干扰 | `_max_foods` 设置上限5个，不随Level无限增加 |

---

*本方案由 Subagent 基于PM反馈生成，待PM/Coder评审后执行*

# 📅 Phase 4 排期计划

> 项目：🐍 贪吃蛇 Snake Game  
> 制作人：PM | 更新日期：2026-03-24  
> 状态：**规划中 — 待团队确认**

---

## 一、Phase 4 范围与工时

| 模块 | Coder | Artist | 说明 |
|------|-------|--------|------|
| ⚡ 道具系统 | 13h | 4h | 6种道具：护盾/减速/穿墙/磁铁/双倍/收缩 |
| 🎨 皮肤系统 | 8h | 6h | 5套免费皮肤 + 皮肤选择UI |
| 🗺️ 地图主题系统 | 5h | 0h | 5套主题颜色 + 粒子装饰 |
| **合计** | **26h** | **10h** | **约5个工作日** |

---

## 二、Sprint 拆分（1 Sprint = 1 天）

> 起始日期：2026-03-31（周一）  
> Phase 3 预计 2026-03-27 完成，Phase 4 间隔1天 buffer

---

### 🏃 Sprint 1（Day 1 — 2026-03-31）

**主题：道具系统 基础设施**

| 角色 | 任务 | 工时 | 交付物 |
|------|------|------|--------|
| Coder | 设计道具管理架构 `powerup_manager.gd`，定义6种道具类型枚举、生成概率、效果参数 | 3h | `powerup_manager.gd` 枚举定义 + 配置表 |
| Coder | 道具生成逻辑（每吃5食50%概率生成，8秒消失，场上最多1个） | 2h | `powerup_manager.gd` 生成/生命周期逻辑 |
| Artist | 制作6种道具图标精灵（32×32，每种1张） | 4h | 6×PNG：`shield.png` / `slow.png` / `ghost.png` / `magnet.png` / `double.png` / `shrink.png` |

**Sprint 1 交付物：**
- ✅ `powerup_manager.gd` 骨架代码（生成/计时/消失逻辑）
- ✅ 6种道具 sprite（静态版）

**依赖：** Phase 3 完成（场地/食物系统就绪）

---

### 🏃 Sprint 2（Day 2 — 2026-04-01）

**主题：道具效果 MVP**

| 角色 | 任务 | 工时 | 交付物 |
|------|------|------|--------|
| Coder | 实现护盾效果（抵挡1次死亡，撞墙/撞身无效） | 2h | `snake.gd` 新增 `apply_shield()` / `consume_shield()` |
| Coder | 实现减速效果（速度 -50%，interval ×2，持续5秒） | 1.5h | `snake.gd` 新增 `apply_slow()` |
| Artist | 护盾泡泡视觉（蓝色半透明圆形围绕蛇身） | 2h | 护盾特效 sprite 或 shader |
| Coder | 连接护盾/减速到主游戏循环（碰撞检测+触发） | 2h | `main.gd` 道具碰撞逻辑 + HUD指示器 |

**Sprint 2 交付物：**
- ✅ 护盾道具完整可用（HUD有护盾图标指示）
- ✅ 减速道具完整可用（速度-50% 5秒）
- ✅ 道具视觉（护盾泡泡）

**依赖：** Sprint 1 完成

---

### 🏃 Sprint 3（Day 3 — 2026-04-02）

**主题：剩余道具 + 集成测试**

| 角色 | 任务 | 工时 | 交付物 |
|------|------|------|--------|
| Coder | 实现穿墙效果（临时禁用自碰撞，3秒） | 1.5h | `snake.gd` `apply_ghost()` 临时穿越自身 |
| Coder | 实现磁铁效果（5格半径吸引食物） | 2h | `magnet.gd` 吸引逻辑 |
| Coder | 实现双倍得分（所有得分×2，持续10秒） | 1h | `score_manager.gd` 乘数逻辑 |
| Coder | 实现收缩效果（蛇身-3节，min_length=3保护） | 1h | `snake.gd` `shrink()` |
| Artist | 各道具视觉（幽灵透明/金色光环/星星/紫色收缩） | 2h | 4种道具视觉特效 sprite |
| Coder | 道具系统集成测试（6种道具全部可触发+消退） | 2h | 测试用例覆盖6种道具 |

**Sprint 3 交付物：**
- ✅ 全部6种道具完整实现
- ✅ 道具系统集成测试通过
- ✅ 道具视觉（幽灵/磁铁/双倍/收缩特效）

**依赖：** Sprint 2 完成

---

### 🏃 Sprint 4（Day 4 — 2026-04-03）

**主题：皮肤系统 MVP**

| 角色 | 任务 | 工时 | 交付物 |
|------|------|------|--------|
| Artist | 设计5套蛇身皮肤概念（Neon绿/Pink/Fire/Ice/Galaxy），只做色彩方案 | 1h | 5套色彩规范（色值文档） |
| Coder | 皮肤加载器架构（`skin_manager.gd` + `snake.gd` 支持多 skin_id 切换） | 3h | `skin_manager.gd` + `snake.gd` 皮肤切换接口 |
| Coder | 成就解锁判定（5个皮肤解锁条件判定 + 存档持久化） | 2h | `savedata.gd` 皮肤解锁字段 |
| Artist | 制作第1套皮肤（默认 Neon Green 完整16张，32×32 PNG） | 2h | `skin_neon_green/` 16张 sprite |

**Sprint 4 交付物：**
- ✅ 5套皮肤色彩方案（设计稿）
- ✅ `skin_manager.gd` 架构
- ✅ `snake.gd` 皮肤切换逻辑
- ✅ 成就解锁判定逻辑
- ✅ 第1套皮肤 Neon Green sprite

**依赖：** Phase 3 蛇身16张基础 sprite 完成

---

### 🏃 Sprint 5（Day 5 — 2026-04-04）

**主题：皮肤完善 + 主题系统**

| 角色 | 任务 | 工时 | 交付物 |
|------|------|------|--------|
| Artist | 制作剩余4套皮肤（Midnight Blue / Golden / Crimson / Aurora） | 6h | `skin_midnight/` / `skin_golden/` / `skin_crimson/` / `skin_aurora/` 各16张 |
| Coder | 皮肤选择UI（开始界面或暂停菜单皮肤预览） | 3h | `skin_selection.gd` + 开始界面皮肤按钮 |
| Coder | 主题系统架构（`theme_manager.gd`，5套主题颜色配置） | 2h | `theme_manager.gd` + 5套颜色配置 |

**Sprint 5 交付物：**
- ✅ 5套皮肤 sprite 全部完成
- ✅ 皮肤选择 UI + 预览
- ✅ `theme_manager.gd` + 5套主题颜色

---

## 三、工时汇总

| 角色 | Sprint 1 | Sprint 2 | Sprint 3 | Sprint 4 | Sprint 5 | **总计** |
|------|----------|----------|----------|----------|----------|---------|
| Coder | 5h | 5.5h | 7.5h | 5h | 5h | **28h** |
| Artist | 4h | 2h | 2h | 3h | 6h | **17h** |

> 注：Artist 工时含 Sprint 3 视觉特效 + Sprint 4/5 皮肤 sprite  
> Coder 总计略超26h预算（+2h buffer），建议 Slack 时间优先用于道具粒子/音效

---

## 四、里程碑路线图

```
2026-03-31  Sprint 1  →  道具基础设施 + 6道具 sprite
2026-04-01  Sprint 2  →  护盾/减速 MVP + 护盾视觉
2026-04-02  Sprint 3  →  全部6种道具完成 + 集成测试
2026-04-03  Sprint 4  →  皮肤系统架构 + 第1套皮肤
2026-04-04  Sprint 5  →  5套皮肤完成 + 皮肤UI + 主题系统

📌 Phase 4 完整交付：2026-04-04（5个工作日）
```

---

## 五、关键依赖

| 依赖项 | 影响范围 | 缓解措施 |
|--------|----------|----------|
| Phase 3 蛇身16张基础 sprite | Sprint 4 皮肤切换 | Phase 3 预计 03-27 完成，有4天 buffer |
| Phase 3 粒子系统 | Sprint 3 道具视觉特效 | 道具粒子复用 Phase 3 粒子架构 |
| Phase 3 存档系统 | Sprint 4 皮肤解锁判定 | 预留 `savedata.gd` 皮肤字段接口 |
| Artist 资源到位 | Sprint 1/2/3/4/5 | Artist 与 Coder 并行，皮肤sprite可后补 |

---

## 六、风险日志

| 风险 | 影响 | 应对 |
|------|------|------|
| 道具过于稀有玩家体验不到 | Phase 4 核心价值打折 | 生成规则：每吃5食50% + 每局10s必出1个，平均每局2-3个 |
| 皮肤 sprite 增大安装包 | 包体超标 | 皮肤启用延迟加载（非启动预加载），ETC1压缩 |
| 低端机道具粒子性能下降 | 帧率下降 | 粒子数量与设备性能挂钩，提供"关闭粒子"选项 |
| Sprint 3 集成测试失败 | Phase 4 延期 | Sprint 2/3 之间预留0.5h buffer 用于修复 |

---

## 七、后续建议（不在 Phase 4 范围内）

- Phase 4.2（可选）：彩虹蛇 + 烈焰蛇 付费皮肤、星空/海洋粒子装饰
- Phase 4.3（可选）：复古街机 Shader、森林草丛贴图
- 封闭测试：根据实际反馈调整道具生成概率和效果参数

/**
 * 此查询旨在评估指向关系在不同上下文深度层级中的分布模式与效率特征：
 * - 唯一浅层计数：仅在最小深度层级上存在的指向关系数量
 * - 总关系计数：在特定深度层级上出现的所有指向关系总和
 * - 浅层效率率：唯一浅层关系占总关系的百分比，用于衡量该层级指向关系的有效性
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 计算指定控制流节点、目标对象和类对象在指向上下文中的深度层级
int calculateContextDepth(ControlFlowNode cfgNode, Object targetObj, ClassObject classObj) {
  // 当存在指向上下文使节点在该上下文中指向对象并关联类对象时，返回该上下文的深度值
  exists(PointsToContext ctx |
    PointsTo::points_to(cfgNode, ctx, targetObj, classObj, _) and
    result = ctx.getDepth()
  )
}

// 获取控制流节点、对象和类对象的最小上下文深度
int findMinimumContextDepth(ControlFlowNode cfgNode, Object targetObj, ClassObject classObj) {
  // 返回所有可能深度值中的最小值
  result = min(int depth | depth = calculateContextDepth(cfgNode, targetObj, classObj))
}

// 分析各深度层级指向关系的分布特征与效率指标
from int currentDepth, 
     int uniqueShallowCount, 
     int totalRelationCount, 
     float shallowEfficiencyRate
where
  // 计算唯一浅层关系：最小深度等于当前深度层级的指向关系数量
  uniqueShallowCount = strictcount(ControlFlowNode cfgNode, Object targetObj, ClassObject classObj |
    currentDepth = findMinimumContextDepth(cfgNode, targetObj, classObj)
  ) and
  // 计算整体频次：深度等于当前深度层级的所有指向关系数量
  totalRelationCount = strictcount(ControlFlowNode cfgNode, Object targetObj, ClassObject classObj, 
                              PointsToContext ctx, ControlFlowNode origin |
    PointsTo::points_to(cfgNode, ctx, targetObj, classObj, origin) and
    currentDepth = ctx.getDepth()
  ) and
  // 避免除以零的错误，确保整体频次大于零
  totalRelationCount > 0 and
  // 计算效率比率：唯一浅层关系占整体频次的百分比
  shallowEfficiencyRate = 100.0 * uniqueShallowCount / totalRelationCount
// 输出深度层级、唯一浅层关系、整体频次和效率比率
select currentDepth, uniqueShallowCount, totalRelationCount, shallowEfficiencyRate
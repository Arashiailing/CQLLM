/**
 * 指向关系深度分布分析：
 * 本查询评估程序中指向关系在不同深度层级的分布特征
 * 
 * 核心指标：
 * - 边缘计数：在最浅深度层级出现的唯一指向关系数量
 * - 实例总数：特定深度层级上的所有指向关系出现次数
 * - 效率指标：边缘计数占实例总数的百分比，反映该深度层级的效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 检索给定控制流节点、对象值和类对象的上下文深度
int retrieveContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 当节点在某个上下文中指向特定对象并关联类对象时，返回该上下文的深度值
  exists(PointsToContext context |
    PointsTo::points_to(node, context, obj, clsObj, _) and
    result = context.getDepth()
  )
}

// 确定给定控制流节点、对象值和类对象的最浅上下文深度
int findShallowestContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 计算所有可能上下文深度的最小值
  result = min(int depth | depth = retrieveContextDepth(node, obj, clsObj))
}

// 分析各深度层级的指向关系分布特征
from int edgeCount, int totalInstances, int depthLevel, float efficiencyMetric
where
  // 计算边缘计数：统计最浅深度等于当前深度层级的唯一指向关系数量
  edgeCount = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj |
    depthLevel = findShallowestContextDepth(node, obj, clsObj)
  ) and
  // 计算实例总数：统计深度等于当前深度层级的所有指向关系数量
  totalInstances = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj, 
                          PointsToContext context, ControlFlowNode origin |
    PointsTo::points_to(node, context, obj, clsObj, origin) and
    depthLevel = context.getDepth()
  ) and
  // 计算效率指标：边缘计数占实例总数的百分比
  totalInstances > 0 and  // 防止除以零错误
  efficiencyMetric = 100.0 * edgeCount / totalInstances
// 输出深度层级、边缘计数、实例总数和效率指标
select depthLevel, edgeCount, totalInstances, efficiencyMetric
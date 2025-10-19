/**
 * 评估指向关系的深度分布特征及其效率指标：
 * - 边际增量：在特定深度首次出现的指向关系数量
 * - 总规模：该深度下所有指向关系的总和
 * - 效率比：边际增量与总规模的比值（百分比形式）
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 确定给定控制流节点、目标对象和类实例的上下文深度
int calculateContextDepth(ControlFlowNode flowNode, Object targetObject, ClassObject classInstance) {
  // 当存在指向上下文使flowNode在该上下文中指向targetObject并关联classInstance时
  exists(PointsToContext pointContext |
    PointsTo::points_to(flowNode, pointContext, targetObject, classInstance, _) and
    result = pointContext.getDepth()
  )
}

// 获取指定控制流节点、目标对象和类实例的最小上下文深度
int findMinimumDepth(ControlFlowNode flowNode, Object targetObject, ClassObject classInstance) {
  // 返回所有可能深度的最小值
  result = min(int depth | depth = calculateContextDepth(flowNode, targetObject, classInstance))
}

// 分析各深度层级的指向关系特征
from int depthLevel, int edgeIncrement, int overallSize, float depthEfficiency
where
  // 边际增量计算：统计最浅深度等于当前层级的唯一指向关系数量
  edgeIncrement = strictcount(ControlFlowNode flowNode, Object targetObject, ClassObject classInstance |
    depthLevel = findMinimumDepth(flowNode, targetObject, classInstance)
  ) and
  // 总规模计算：统计深度等于当前层级的所有指向关系数量
  overallSize = strictcount(ControlFlowNode flowNode, Object targetObject, ClassObject classInstance, 
                          PointsToContext pointContext, ControlFlowNode sourceNode |
    PointsTo::points_to(flowNode, pointContext, targetObject, classInstance, sourceNode) and
    depthLevel = pointContext.getDepth()
  ) and
  // 效率比计算：边际增量占总规模的百分比
  depthEfficiency = 100.0 * edgeIncrement / overallSize
// 输出各深度层级及其对应的边际增量、总规模和效率比
select depthLevel, edgeIncrement, overallSize, depthEfficiency
/**
 * 指向关系深度层次分析：
 * 对代码库中不同深度的指向关系进行量化分析，包括：
 * - 独特关系数：在最浅深度层出现的独特指向关系数量
 * - 全部关系数：特定深度层的所有指向关系总数
 * - 效率度量：独特关系数占全部关系数的百分比
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 检索控制流节点在指定目标对象和类对象下的上下文深度
int retrieveContextDepth(ControlFlowNode cfNode, Object targetObject, ClassObject classObject) {
  // 当节点在某个上下文中指向目标对象并关联类对象时，返回该上下文深度
  exists(PointsToContext context |
    PointsTo::points_to(cfNode, context, targetObject, classObject, _) and
    result = context.getDepth()
  )
}

// 查找控制流节点在指定目标对象和类对象下的最小上下文深度
int findMinimumContextDepth(ControlFlowNode cfNode, Object targetObject, ClassObject classObject) {
  // 返回所有可能深度的最小值
  result = min(int depth | depth = retrieveContextDepth(cfNode, targetObject, classObject))
}

// 分析不同深度层的指向关系特征
from int depthTier, int distinctRelations, int overallRelations
where
  // 计算独特关系数：最浅深度等于当前深度的独特指向关系数量
  distinctRelations = strictcount(ControlFlowNode cfNode, Object targetObject, ClassObject classObject |
    depthTier = findMinimumContextDepth(cfNode, targetObject, classObject)
  ) and
  // 计算全部关系数：深度等于当前深度的所有指向关系数量
  overallRelations = strictcount(ControlFlowNode cfNode, Object targetObject, ClassObject classObject, 
                                PointsToContext context, ControlFlowNode sourceNode |
    PointsTo::points_to(cfNode, context, targetObject, classObject, sourceNode) and
    depthTier = context.getDepth()
  ) and
  // 确保全部关系数大于零，防止除零错误
  overallRelations > 0
// 输出结果：深度层、独特关系数、全部关系数和效率度量
select depthTier, distinctRelations, overallRelations, 100.0 * distinctRelations / overallRelations
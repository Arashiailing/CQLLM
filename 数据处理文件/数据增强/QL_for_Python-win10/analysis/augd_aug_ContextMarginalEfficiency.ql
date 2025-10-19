/**
 * 评估指向关系的深度分布特征：
 * - 边际关系：在最浅深度层级上出现的唯一指向关系数量
 * - 整体关系：在所有深度层级上的指向关系总和
 * - 深度效率：边际关系占整体关系的百分比
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 确定给定控制流节点、对象和类对象的上下文深度
int calculateContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 查找指向上下文，其中node在该上下文中指向obj并与clsObj关联
  exists(PointsToContext context |
    PointsTo::points_to(node, context, obj, clsObj, _) and
    result = context.getDepth()
  )
}

// 获取指定控制流节点、对象和类对象的最小上下文深度
int findMinimumContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 返回所有可能深度的最小值
  result = min(int depth | depth = calculateContextDepth(node, obj, clsObj))
}

// 分析不同深度层级上的指向关系特征
from int edgeRelations, int overallRelations, int depthLevel, float depthEfficiency
where
  // 计算边际关系：最浅深度等于当前层级的唯一指向关系数量
  edgeRelations = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj |
    depthLevel = findMinimumContextDepth(node, obj, clsObj)
  ) and
  // 计算整体关系：深度等于当前层级的所有指向关系数量
  overallRelations = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj, 
                          PointsToContext context, ControlFlowNode origin |
    PointsTo::points_to(node, context, obj, clsObj, origin) and
    depthLevel = context.getDepth()
  ) and
  // 计算深度效率：边际关系占整体关系的百分比
  depthEfficiency = 100.0 * edgeRelations / overallRelations
// 输出深度层级、边际关系、整体关系和深度效率
select depthLevel, edgeRelations, overallRelations, depthEfficiency
/**
 * 深度层级指向关系特征分析：
 * - 唯一边界关系：在最浅深度层级上出现的不同指向关系数量
 * - 累计出现频次：在特定深度层级上的指向关系总次数
 * - 深度效率值：唯一边界关系占累计出现频次的比例，反映该深度层级的效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 获取控制流节点、目标对象和类对象对应的上下文深度值
int retrieveContextDepth(ControlFlowNode flowNode, Object targetObj, ClassObject classObj) {
  // 当存在指向上下文使节点在该上下文中指向目标对象并关联类对象时，返回该上下文的深度
  exists(PointsToContext ctx |
    PointsTo::points_to(flowNode, ctx, targetObj, classObj, _) and
    result = ctx.getDepth()
  )
}

// 获取控制流节点、目标对象和类对象的最小上下文深度
int retrieveMinContextDepth(ControlFlowNode flowNode, Object targetObj, ClassObject classObj) {
  // 返回所有可能深度的最小值
  result = min(int depthVal | depthVal = retrieveContextDepth(flowNode, targetObj, classObj))
}

// 分析不同深度层级的指向关系统计特征
from int uniqueBoundaryRelations, int cumulativeFrequency, int depthLevel, float depthEfficiency
where
  // 计算唯一边界关系：最浅深度等于当前深度层级的不同指向关系数量
  uniqueBoundaryRelations = strictcount(ControlFlowNode flowNode, Object targetObj, ClassObject classObj |
    depthLevel = retrieveMinContextDepth(flowNode, targetObj, classObj)
  ) and
  // 计算累计出现频次：深度等于当前深度层级的所有指向关系数量
  cumulativeFrequency = strictcount(ControlFlowNode flowNode, Object targetObj, ClassObject classObj, 
                          PointsToContext ctx, ControlFlowNode originNode |
    PointsTo::points_to(flowNode, ctx, targetObj, classObj, originNode) and
    depthLevel = ctx.getDepth()
  ) and
  // 计算深度效率值：唯一边界关系占累计出现频次的百分比
  cumulativeFrequency > 0 and  // 避免除以零
  depthEfficiency = 100.0 * uniqueBoundaryRelations / cumulativeFrequency
// 输出深度层级、唯一边界关系、累计出现频次和深度效率值
select depthLevel, uniqueBoundaryRelations, cumulativeFrequency, depthEfficiency
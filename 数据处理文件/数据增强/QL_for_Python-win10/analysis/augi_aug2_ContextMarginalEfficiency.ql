/**
 * 分析指向关系数据在不同上下文深度下的分布特征。
 * 该查询计算：
 * 1. 边际增加的指向关系事实数量（最浅深度等于当前深度的三元组数量）
 * 2. 指向关系的总大小（上下文深度等于当前深度的五元组数量）
 * 3. 效率比例（事实数量占总大小的百分比）
 * 
 * 通过这些指标可以评估上下文敏感分析在不同深度下的精确度和开销。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 获取给定控制流节点、目标对象和类对象的上下文深度
int getContextDepth(ControlFlowNode cfgNode, Object targetObj, ClassObject classObj) {
  exists(PointsToContext ptContext |
    PointsTo::points_to(cfgNode, ptContext, targetObj, classObj, _) and
    result = ptContext.getDepth()
  )
}

// 获取给定控制流节点、目标对象和类对象的最浅上下文深度
int getShallowestDepth(ControlFlowNode cfgNode, Object targetObj, ClassObject classObj) {
  result = min(int d | d = getContextDepth(cfgNode, targetObj, classObj))
}

// 分析不同上下文深度下的指向关系特征
from int contextDepthLevel, int marginalFactsCount, int totalRelationsCount, float precisionRatio
where
  // 计算边际增加的指向关系事实数量
  marginalFactsCount = strictcount(ControlFlowNode cfgNode, Object targetObj, ClassObject classObj |
    getShallowestDepth(cfgNode, targetObj, classObj) = contextDepthLevel
  ) and
  // 计算指向关系的总大小
  totalRelationsCount = strictcount(ControlFlowNode cfgNode, Object targetObj, ClassObject classObj, 
                                    PointsToContext ptContext, ControlFlowNode originNode |
    PointsTo::points_to(cfgNode, ptContext, targetObj, classObj, originNode) and
    ptContext.getDepth() = contextDepthLevel
  ) and
  // 计算精确度比例（边际事实数量占总关系数量的百分比）
  precisionRatio = 100.0 * marginalFactsCount / totalRelationsCount
select contextDepthLevel, marginalFactsCount, totalRelationsCount, precisionRatio
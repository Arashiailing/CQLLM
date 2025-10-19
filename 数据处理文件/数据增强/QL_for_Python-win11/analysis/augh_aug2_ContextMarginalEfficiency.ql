/**
 * 分析指向关系的边际增长与总体规模：
 * 本查询计算在不同上下文深度下，边际增加的指向关系事实数量、指向关系的总体规模，
 * 以及边际事实相对于总体规模的比例（效率指标）。
 * 这有助于理解上下文敏感性对指向分析精度的影响。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

/**
 * 获取指定控制流节点、目标对象和类对象所关联的上下文深度。
 * @param flowNode - 控制流节点
 * @param targetObj - 目标对象
 * @param classObj - 类对象
 * @return - 上下文深度值
 */
int getContextDepth(ControlFlowNode flowNode, Object targetObj, ClassObject classObj) {
  exists(PointsToContext ctx |
    PointsTo::points_to(flowNode, ctx, targetObj, classObj, _) and
    result = ctx.getDepth()
  )
}

/**
 * 计算指定控制流节点、目标对象和类对象的最浅上下文深度。
 * @param flowNode - 控制流节点
 * @param targetObj - 目标对象
 * @param classObj - 类对象
 * @return - 最浅上下文深度值
 */
int getMinimalDepth(ControlFlowNode flowNode, Object targetObj, ClassObject classObj) {
  result = min(int depthVal | depthVal = getContextDepth(flowNode, targetObj, classObj))
}

/**
 * 主查询：计算并展示不同上下文深度下的指向关系统计信息
 */
from int depth, int marginalFacts, int overallSize, float efficiencyRatio
where
  // 计算边际事实数：在最浅深度等于当前深度的三元组数量
  marginalFacts = strictcount(ControlFlowNode flowNode, Object targetObj, ClassObject classObj |
    getMinimalDepth(flowNode, targetObj, classObj) = depth
  ) and
  // 计算总体规模：在上下文深度等于当前深度的五元组数量
  overallSize = strictcount(ControlFlowNode flowNode, Object targetObj, ClassObject classObj, 
                          PointsToContext ctx, ControlFlowNode origin |
    PointsTo::points_to(flowNode, ctx, targetObj, classObj, origin) and
    ctx.getDepth() = depth
  ) and
  // 计算效率比例：边际事实占总体的百分比
  efficiencyRatio = 100.0 * marginalFacts / overallSize
select depth, marginalFacts, overallSize, efficiencyRatio
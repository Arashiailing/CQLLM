/**
 * 分析指向关系的边际增量、总规模及深度效率比：
 * - 边际增量：最浅深度下的唯一指向关系数量
 * - 总规模：所有深度下的指向关系总数
 * - 效率比：边际增量占总规模的百分比
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 计算指定控制流节点、对象值和类对象的上下文深度
int getContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 存在指向上下文context，使node在context中指向obj且关联clsObj
  exists(PointsToContext context |
    PointsTo::points_to(node, context, obj, clsObj, _) and
    result = context.getDepth()
  )
}

// 计算指定控制流节点、对象值和类对象的最浅上下文深度
int getShallowestDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 返回所有可能深度的最小值
  result = min(int depth | depth = getContextDepth(node, obj, clsObj))
}

// 分析不同深度下的指向关系指标
from int marginalFacts, int totalFacts, int currentDepth, float efficiencyRatio
where
  // 计算边际增量：最浅深度等于当前深度的唯一指向关系数量
  marginalFacts = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj |
    currentDepth = getShallowestDepth(node, obj, clsObj)
  ) and
  // 计算总规模：深度等于当前深度的所有指向关系数量
  totalFacts = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj, 
                          PointsToContext context, ControlFlowNode origin |
    PointsTo::points_to(node, context, obj, clsObj, origin) and
    currentDepth = context.getDepth()
  ) and
  // 计算效率比：边际增量占总规模的百分比
  efficiencyRatio = 100.0 * marginalFacts / totalFacts
// 输出深度、边际增量、总规模和效率比
select currentDepth, marginalFacts, totalFacts, efficiencyRatio
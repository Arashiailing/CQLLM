/**
 * 分析指向关系的深度分布特征：
 * - 边界计数：在最浅深度层级上出现的唯一指向关系数量
 * - 总出现次数：在特定深度层级上的所有指向关系总数
 * - 效率比率：边界计数占总出现次数的比例，表示该深度层级的效率
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 获取指定控制流节点、对象值和类对象的上下文深度
int getContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 当存在一个指向上下文，使得节点在该上下文中指向对象并关联类对象时，返回该上下文的深度
  exists(PointsToContext context |
    PointsTo::points_to(node, context, obj, clsObj, _) and
    result = context.getDepth()
  )
}

// 获取指定控制流节点、对象值和类对象的最浅上下文深度
int getMinimumContextDepth(ControlFlowNode node, Object obj, ClassObject clsObj) {
  // 返回所有可能深度的最小值
  result = min(int depth | depth = getContextDepth(node, obj, clsObj))
}

// 分析各深度层级的指向关系特征
from int boundaryCount, int totalOccurrences, int currentDepth, float efficiencyRatio
where
  // 计算边界计数：最浅深度等于当前深度层级的唯一指向关系数量
  boundaryCount = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj |
    currentDepth = getMinimumContextDepth(node, obj, clsObj)
  ) and
  // 计算总出现次数：深度等于当前深度层级的所有指向关系数量
  totalOccurrences = strictcount(ControlFlowNode node, Object obj, ClassObject clsObj, 
                          PointsToContext context, ControlFlowNode origin |
    PointsTo::points_to(node, context, obj, clsObj, origin) and
    currentDepth = context.getDepth()
  ) and
  // 计算效率比率：边界计数占总出现次数的百分比
  totalOccurrences > 0 and  // 避免除以零
  efficiencyRatio = 100.0 * boundaryCount / totalOccurrences
// 输出深度层级、边界计数、总出现次数和效率比率
select currentDepth, boundaryCount, totalOccurrences, efficiencyRatio
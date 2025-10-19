/**
 * 分析指向关系的增量事实、总规模及深度相关效率指标
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 计算控制流节点、目标对象及类对象在指向上下文中的深度层级
int getContextDepth(ControlFlowNode node, Object obj, ClassObject classObj) {
  exists(PointsToContext context |
    PointsTo::points_to(node, context, obj, classObj, _) and
    result = context.getDepth()
  )
}

// 获取控制流节点、目标对象及类对象的最浅上下文深度
int getMinDepth(ControlFlowNode node, Object obj, ClassObject classObj) {
  result = min(int currentDepth | currentDepth = getContextDepth(node, obj, classObj))
}

// 输出深度层级、增量事实数、总规模事实数及效率百分比
from int factCount, int totalSize, int depthLevel, float efficiencyRatio
where
  // 统计最浅深度对应的增量事实数量
  factCount =
    strictcount(ControlFlowNode node, Object obj, ClassObject classObj |
      depthLevel = getMinDepth(node, obj, classObj)
    ) and
  // 统计所有深度匹配的总指向事实规模
  totalSize =
    strictcount(ControlFlowNode node, Object obj, ClassObject classObj, 
                PointsToContext context, ControlFlowNode origin |
      PointsTo::points_to(node, context, obj, classObj, origin) and
      depthLevel = context.getDepth()
    ) and
  // 计算效率比率（增量事实占比）
  efficiencyRatio = 100.0 * factCount / totalSize
select depthLevel, factCount, totalSize, efficiencyRatio
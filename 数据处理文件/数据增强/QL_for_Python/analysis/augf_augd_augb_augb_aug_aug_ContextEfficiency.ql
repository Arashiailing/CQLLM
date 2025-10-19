/**
 * 指针分析压缩性能度量：此查询旨在通过分析不同上下文层级中唯一事实数量
 * 与整体关系规模的比例，来评估指针分析数据结构的压缩效果和算法效率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 声明输出变量：唯一事实计数、关系总数、上下文深度和压缩比率
from int distinctFactsCount, int totalRelationCount, int ctxDepth, float efficiencyRatio
where
  // 统计唯一事实数量：计算不同的(控制流节点, 指向对象, 目标类)三元组数量
  distinctFactsCount =
    strictcount(ControlFlowNode node, Object targetObj, ClassObject targetCls |
      exists(PointsToContext ctx |
        // 确认在指定上下文中，节点指向目标对象，且该对象实例化自目标类
        PointsTo::points_to(node, ctx, targetObj, targetCls, _) and
        ctxDepth = ctx.getDepth()
      )
    ) and
  // 统计关系总数：计算包含完整上下文和源节点信息的所有指向关系
  totalRelationCount =
    strictcount(ControlFlowNode node, Object targetObj, ClassObject targetCls, 
      PointsToContext ctx, ControlFlowNode srcNode |
      // 验证完整的指向关系，包括源控制流节点
      PointsTo::points_to(node, ctx, targetObj, targetCls, srcNode) and
      ctxDepth = ctx.getDepth()
    ) and
  // 计算压缩效率：唯一事实数量占总关系数量的百分比
  efficiencyRatio = 100.0 * distinctFactsCount / totalRelationCount
// 输出分析结果：上下文深度、唯一事实计数、关系总数和压缩效率比率
select ctxDepth, distinctFactsCount, totalRelationCount, efficiencyRatio
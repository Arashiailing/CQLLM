/**
 * 指向关系压缩效率分析：评估不同上下文深度下的数据压缩情况。
 * 该查询计算唯一事实数量、总关系数量，并导出压缩比率指标。
 * 压缩比率衡量唯一事实占总关系的百分比，反映了指向关系的压缩效率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询结果变量：distinctFactsCount（唯一事实数量）、totalRelationsCount（总关系数量）、contextDepth（上下文深度）和compressionRatio（压缩比率）
from int distinctFactsCount, int totalRelationsCount, int contextDepth, float compressionRatio
where
  // 计算唯一事实数量：统计不同的(控制流节点, 对象, 类对象)组合
  distinctFactsCount =
    strictcount(ControlFlowNode flowNode, Object objValue, ClassObject classObj |
      exists(PointsToContext context |
        // 验证在指定上下文中，控制流节点指向特定对象和类对象
        PointsTo::points_to(flowNode, context, objValue, classObj, _) and
        contextDepth = context.getDepth()
      )
    ) and
  // 计算总关系数量：统计所有(控制流节点, 对象, 类对象, 上下文, 源节点)组合
  totalRelationsCount =
    strictcount(ControlFlowNode flowNode, Object objValue, ClassObject classObj, 
      PointsToContext context, ControlFlowNode originNode |
      // 验证在指定上下文中，控制流节点指向特定对象和类对象，并记录源节点
      PointsTo::points_to(flowNode, context, objValue, classObj, originNode) and
      contextDepth = context.getDepth()
    ) and
  // 计算压缩比率：唯一事实数量占总关系数量的百分比
  compressionRatio = 100.0 * distinctFactsCount / totalRelationsCount
// 输出结果：上下文深度、唯一事实数量、总关系数量和压缩比率
select contextDepth, distinctFactsCount, totalRelationsCount, compressionRatio
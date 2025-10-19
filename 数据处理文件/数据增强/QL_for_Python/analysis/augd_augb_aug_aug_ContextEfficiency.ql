/**
 * 评估指向关系数据结构的压缩性能：通过分析不同上下文深度下
 * 唯一事实数量与总关系规模的比率，量化数据压缩效率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实计数、关系总规模、上下文深度和压缩比率
from int unique_facts_count, int total_relations_size, int ctx_depth, float compression_ratio
where
  // 计算唯一事实数量：统计不同的(控制流节点, 目标对象, 对象类型)组合数量
  unique_facts_count =
    strictcount(ControlFlowNode node, Object target, ClassObject type |
      exists(PointsToContext context |
        // 确认在指定上下文中，控制流节点指向目标对象，且该对象属于特定类型
        PointsTo::points_to(node, context, target, type, _) and
        ctx_depth = context.getDepth()
      )
    ) and
  // 计算关系总规模：统计所有(控制流节点, 目标对象, 对象类型, 上下文, 源节点)组合数量
  total_relations_size =
    strictcount(ControlFlowNode node, Object target, ClassObject type, 
      PointsToContext context, ControlFlowNode source |
      // 验证完整的指向关系，包括源节点信息
      PointsTo::points_to(node, context, target, type, source) and
      ctx_depth = context.getDepth()
    ) and
  // 计算压缩比率：唯一事实数量占总关系规模的百分比
  compression_ratio = 100.0 * unique_facts_count / total_relations_size
// 输出结果：上下文深度、唯一事实数量、关系总规模和压缩比率
select ctx_depth, unique_facts_count, total_relations_size, compression_ratio
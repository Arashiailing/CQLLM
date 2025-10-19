/**
 * 评估指向关系数据结构的压缩效率：通过分析不同上下文深度下的数据压缩情况，
 * 计算去重后的关键事实数量与完整关系数据集的比率，从而量化压缩性能表现。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实计数、总关系规模、上下文深度和压缩比率
from int unique_facts_count, int total_relations_size, int ctx_depth, float compression_ratio
where
  // 计算唯一事实数量：统计不重复的(控制流节点, 指向对象, 目标类)三元组
  unique_facts_count =
    strictcount(ControlFlowNode node, Object pointed_obj, ClassObject target_class |
      exists(PointsToContext context |
        // 验证在给定上下文中，节点指向特定对象且该对象属于特定类
        PointsTo::points_to(node, context, pointed_obj, target_class, _) and
        ctx_depth = context.getDepth()
      )
    ) and
  // 计算总关系规模：统计所有完整的(控制流节点, 指向对象, 目标类, 上下文, 源节点)五元组
  total_relations_size =
    strictcount(ControlFlowNode node, Object pointed_obj, ClassObject target_class, 
      PointsToContext context, ControlFlowNode origin_node |
      // 验证完整的指向关系，包括源节点信息
      PointsTo::points_to(node, context, pointed_obj, target_class, origin_node) and
      ctx_depth = context.getDepth()
    ) and
  // 计算压缩效率比率：唯一事实数量占总关系规模的百分比
  compression_ratio = 100.0 * unique_facts_count / total_relations_size
// 输出结果：上下文深度、唯一事实数量、总关系规模和压缩效率比率
select ctx_depth, unique_facts_count, total_relations_size, compression_ratio
/**
 * 评估指向关系数据结构的压缩效率：该查询通过分析不同上下文深度下
 * 的唯一事实数量与总关系规模的比例，来量化数据压缩的性能表现。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出参数：唯一事实计数、关系总规模、上下文深度和压缩效率指标
from int unique_facts_count, int total_relations_size, int context_depth, float compression_ratio
where
  // 计算唯一事实数量：统计不同的(源控制流节点, 指向对象, 对象类)组合数
  unique_facts_count =
    strictcount(ControlFlowNode source_flow_node, Object pointed_object, ClassObject object_class |
      exists(PointsToContext context_data |
        // 验证在指定上下文中，源控制流节点指向目标对象，且该对象属于特定类
        PointsTo::points_to(source_flow_node, context_data, pointed_object, object_class, _) and
        context_depth = context_data.getDepth()
      )
    ) and
  // 计算关系总规模：统计所有(源控制流节点, 指向对象, 对象类, 上下文数据, 源节点)组合数
  total_relations_size =
    strictcount(ControlFlowNode source_flow_node, Object pointed_object, ClassObject object_class, 
      PointsToContext context_data, ControlFlowNode origin_node |
      // 验证完整的指向关系，包括源节点信息
      PointsTo::points_to(source_flow_node, context_data, pointed_object, object_class, origin_node) and
      context_depth = context_data.getDepth()
    ) and
  // 计算压缩效率：唯一事实数量占总关系规模的百分比
  compression_ratio = 100.0 * unique_facts_count / total_relations_size
// 输出分析结果：上下文深度、唯一事实数量、关系总规模和压缩效率
select context_depth, unique_facts_count, total_relations_size, compression_ratio
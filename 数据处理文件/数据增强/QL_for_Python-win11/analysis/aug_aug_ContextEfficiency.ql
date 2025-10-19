/**
 * 评估指向关系数据结构的压缩效果：通过计算不同上下文深度下的
 * 唯一事实数量与关系总规模，分析压缩效率指标。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实计数、关系规模、上下文深度和压缩效率指标
from int unique_facts_count, int total_relations_size, int ctx_depth, float compression_efficiency
where
  // 计算唯一事实数量：统计不同的(控制流节点, 指向对象, 对象类)三元组
  unique_facts_count =
    strictcount(ControlFlowNode cfg_node, Object pointed_object, ClassObject object_class |
      exists(PointsToContext points_to_context |
        // 验证在指定上下文中，控制流节点是否指向特定对象，且该对象属于特定类
        PointsTo::points_to(cfg_node, points_to_context, pointed_object, object_class, _) and
        ctx_depth = points_to_context.getDepth()
      )
    ) and
  // 计算关系总规模：统计所有(控制流节点, 指向对象, 对象类, 上下文, 源节点)五元组
  total_relations_size =
    strictcount(ControlFlowNode cfg_node, Object pointed_object, ClassObject object_class, 
      PointsToContext points_to_context, ControlFlowNode origin_node |
      // 验证完整指向关系，包括源节点信息
      PointsTo::points_to(cfg_node, points_to_context, pointed_object, object_class, origin_node) and
      ctx_depth = points_to_context.getDepth()
    ) and
  // 计算压缩效率：唯一事实数量占关系总规模的百分比
  compression_efficiency = 100.0 * unique_facts_count / total_relations_size
// 输出结果：上下文深度、唯一事实数量、关系总规模和压缩效率
select ctx_depth, unique_facts_count, total_relations_size, compression_efficiency
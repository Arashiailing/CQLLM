/**
 * 分析指向关系数据结构的压缩特性：通过测量不同上下文深度下
 * 去重后的事实数量与完整关系规模的比例，评估压缩性能指标。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 声明查询结果变量：去重事实计数、完整关系规模、上下文深度和压缩性能指标
from int distinct_facts_count, int overall_relations_size, int context_depth, float efficiency_ratio
where
  // 计算去重后的事实数量：统计不同的(控制流节点, 指向对象, 对象类)组合
  distinct_facts_count =
    strictcount(ControlFlowNode flow_node, Object target_obj, ClassObject obj_class |
      exists(PointsToContext pt_context |
        // 确认在特定上下文中，控制流节点指向特定对象，且该对象属于特定类
        PointsTo::points_to(flow_node, pt_context, target_obj, obj_class, _) and
        context_depth = pt_context.getDepth()
      )
    ) and
  // 计算完整关系规模：统计所有(控制流节点, 指向对象, 对象类, 上下文, 源节点)组合
  overall_relations_size =
    strictcount(ControlFlowNode flow_node, Object target_obj, ClassObject obj_class, 
      PointsToContext pt_context, ControlFlowNode source_node |
      // 确认完整的指向关系，包括源节点信息
      PointsTo::points_to(flow_node, pt_context, target_obj, obj_class, source_node) and
      context_depth = pt_context.getDepth()
    ) and
  // 计算压缩性能：去重事实数量占完整关系规模的百分比
  efficiency_ratio = 100.0 * distinct_facts_count / overall_relations_size
// 输出结果：上下文深度、去重事实数量、完整关系规模和压缩性能
select context_depth, distinct_facts_count, overall_relations_size, efficiency_ratio
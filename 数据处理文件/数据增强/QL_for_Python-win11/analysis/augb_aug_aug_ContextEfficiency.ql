/**
 * 分析指向关系数据结构的压缩效率：通过测量不同上下文深度下的
 * 唯一事实数量与总关系规模的比例，评估数据压缩性能。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 声明查询输出变量：唯一事实计数、关系总规模、上下文深度和效率指标
from int distinct_facts_count, int overall_relations_volume, int context_depth, float efficiency_metric
where
  // 计算唯一事实数量：统计不同的(控制流节点, 目标对象, 对象类型)组合
  distinct_facts_count =
    strictcount(ControlFlowNode flow_node, Object target_object, ClassObject object_type |
      exists(PointsToContext context_info |
        // 验证在特定上下文中，控制流节点指向目标对象，且该对象属于特定类型
        PointsTo::points_to(flow_node, context_info, target_object, object_type, _) and
        context_depth = context_info.getDepth()
      )
    ) and
  // 计算关系总规模：统计所有(控制流节点, 目标对象, 对象类型, 上下文, 源节点)组合
  overall_relations_volume =
    strictcount(ControlFlowNode flow_node, Object target_object, ClassObject object_type, 
      PointsToContext context_info, ControlFlowNode source_node |
      // 验证完整的指向关系，包括源节点信息
      PointsTo::points_to(flow_node, context_info, target_object, object_type, source_node) and
      context_depth = context_info.getDepth()
    ) and
  // 计算压缩效率：唯一事实数量占总关系规模的百分比
  efficiency_metric = 100.0 * distinct_facts_count / overall_relations_volume
// 输出结果：上下文深度、唯一事实数量、关系总规模和压缩效率
select context_depth, distinct_facts_count, overall_relations_volume, efficiency_metric
/**
 * 分析指向关系的压缩效率：计算唯一事实数量、总关系数量以及压缩比率。
 * 压缩比率表示唯一事实占总关系的百分比，反映了指向关系的压缩效率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询结果变量：unique_facts_count（唯一事实数量）、total_relations_count（总关系数量）、context_depth（上下文深度）和compression_ratio（压缩比率）
from int unique_facts_count, int total_relations_count, int context_depth, float compression_ratio
where
  // 计算唯一事实数量：统计不同的(控制流节点, 对象, 类对象)组合
  unique_facts_count =
    strictcount(ControlFlowNode flow_node, Object obj_value, ClassObject class_obj |
      exists(PointsToContext context |
        // 检查在给定上下文中，控制流节点是否指向特定对象和类对象
        PointsTo::points_to(flow_node, context, obj_value, class_obj, _) and
        context_depth = context.getDepth()
      )
    ) and
  // 计算总关系数量：统计所有(控制流节点, 对象, 类对象, 上下文, 源节点)组合
  total_relations_count =
    strictcount(ControlFlowNode flow_node, Object obj_value, ClassObject class_obj, 
      PointsToContext context, ControlFlowNode origin_node |
      // 检查在给定上下文中，控制流节点是否指向特定对象和类对象，并记录源节点
      PointsTo::points_to(flow_node, context, obj_value, class_obj, origin_node) and
      context_depth = context.getDepth()
    ) and
  // 计算压缩比率：唯一事实数量占总关系数量的百分比
  compression_ratio = 100.0 * unique_facts_count / total_relations_count
// 选择要显示的结果字段：上下文深度、唯一事实数量、总关系数量和压缩比率
select context_depth, unique_facts_count, total_relations_count, compression_ratio
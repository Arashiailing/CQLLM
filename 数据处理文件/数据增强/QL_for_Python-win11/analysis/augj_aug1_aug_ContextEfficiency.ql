/**
 * 分析指向关系图的压缩性能：测量不同上下文深度下的唯一事实数量、
 * 关系图总体规模，以及压缩比率（唯一事实占总关系的百分比）。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：唯一事实数量、关系总规模、上下文深度和压缩比率
from int distinct_facts_num, int relations_total_size, int context_depth, float compression_ratio
where
  // 获取当前分析的上下文深度
  exists(PointsToContext ctx | context_depth = ctx.getDepth()) and
  // 计算唯一事实数量：统计不同的(控制流节点, 目标对象, 类对象)组合数
  distinct_facts_num = strictcount(ControlFlowNode flow_node, Object target_object, ClassObject class_obj |
    exists(PointsToContext ctx |
      // 验证在特定上下文中，控制流节点指向目标对象，且该对象是类对象的实例
      PointsTo::points_to(flow_node, ctx, target_object, class_obj, _) and
      ctx.getDepth() = context_depth
    )
  ) and
  // 计算关系总规模：统计所有(控制流节点, 目标对象, 类对象, 上下文, 源控制流节点)组合数
  relations_total_size = strictcount(
    ControlFlowNode flow_node, Object target_object, ClassObject class_obj, 
    PointsToContext ctx, ControlFlowNode source_flow_node |
    // 验证在特定上下文中，控制流节点指向目标对象，且该对象是类对象的实例，同时记录源控制流节点
    PointsTo::points_to(flow_node, ctx, target_object, class_obj, source_flow_node) and
    ctx.getDepth() = context_depth
  ) and
  // 计算压缩比率：唯一事实数量占关系总规模的百分比
  compression_ratio = 100.0 * distinct_facts_num / relations_total_size
// 输出结果：上下文深度、唯一事实数量、关系总规模和压缩比率
select context_depth, distinct_facts_num, relations_total_size, compression_ratio
/**
 * 分析调用图在不同上下文深度下的边际增长特性，包括新增事实数量、总规模及效率比率。
 * 该查询用于评估调用图分析在深度增加时的信息增益与计算开销的平衡。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询结果变量：unique_call_nodes（唯一调用节点数）、overall_call_count（总调用数）、context_depth（上下文深度）和efficiency_ratio（效率比率）
from int unique_call_nodes, int overall_call_count, int context_depth, float efficiency_ratio
where
  // 计算在给定深度下的唯一调用节点数量
  unique_call_nodes =
    strictcount(ControlFlowNode call_node, CallableValue callable |
      exists(PointsToContext analysis_context |
        call_node = callable.getACall(analysis_context) and // 获取函数在特定上下文中的调用节点
        context_depth = analysis_context.getDepth() and // 获取上下文的深度
        not exists(PointsToContext shallower_context |
          call_node = callable.getACall(shallower_context) and // 确保没有更浅的上下文包含相同的调用节点
          shallower_context.getDepth() < context_depth
        )
      )
    ) and
  // 计算所有上下文中的调用节点总数
  overall_call_count =
    strictcount(ControlFlowNode call_node, CallableValue callable, PointsToContext analysis_context |
      call_node = callable.getACall(analysis_context) and // 获取函数在任意上下文中的调用节点
      context_depth = analysis_context.getDepth() // 获取上下文的深度
    ) and
  // 计算效率比率，即唯一调用节点数与总调用数的百分比
  efficiency_ratio = 100.0 * unique_call_nodes / overall_call_count
select context_depth, unique_call_nodes, overall_call_count, efficiency_ratio // 选择要显示的结果字段
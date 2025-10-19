/**
 * 调用图深度增长特性分析
 * 
 * 此查询旨在研究调用图在不同上下文深度下的增长模式，通过计算以下指标来量化分析：
 * 1. 新增节点数（new_nodes_at_depth）：在特定深度首次出现的调用节点数量
 * 2. 总节点数（total_nodes_at_depth）：在该深度下的所有调用节点数量
 * 3. 增长百分比（growth_percentage）：新增节点数占总节点数的比例，表示调用图的边际增长率
 * 
 * 这些指标有助于理解调用图在深度增加时的扩展特性，为程序分析提供性能洞察。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 查询结果变量：深度级别、新增节点数、总节点数和增长百分比
from int new_nodes_at_depth, int total_nodes_at_depth, int depth_level, float growth_percentage
where
  // 计算在给定深度首次出现的调用节点数量（新增节点数）
  new_nodes_at_depth =
    strictcount(ControlFlowNode call_node, CallableValue callable |
      exists(PointsToContext context |
        // 调用节点在指定深度下存在
        call_node = callable.getACall(context) and
        depth_level = context.getDepth() and
        // 调用节点在更浅的深度下不存在（确保是首次出现）
        not exists(PointsToContext shallow_context |
          call_node = callable.getACall(shallow_context) and
          shallow_context.getDepth() < depth_level
        )
      )
    ) and
  // 计算在给定深度下的所有调用节点数量（总节点数）
  total_nodes_at_depth =
    strictcount(ControlFlowNode call_node, CallableValue callable, PointsToContext context |
      call_node = callable.getACall(context) and
      depth_level = context.getDepth()
    ) and
  // 计算增长百分比：新增节点数占总节点数的比例
  growth_percentage = 100.0 * new_nodes_at_depth / total_nodes_at_depth
select depth_level, new_nodes_at_depth, total_nodes_at_depth, growth_percentage
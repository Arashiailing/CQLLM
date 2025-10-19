/**
 * 本查询用于分析Python代码中的指向关系统计数据，包括:
 * 1. 指向事实的数量统计
 * 2. 指向关系的总体大小
 * 3. 基于上下文深度的压缩比率计算
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：指向事实计数、关系大小、上下文深度和压缩比率
from int fact_count, int relation_size, int context_depth, float compression_ratio
where
  // 计算指向事实的数量：统计所有唯一(f, value, cls)组合
  fact_count =
    strictcount(ControlFlowNode f, Object value, ClassObject cls |
      exists(PointsToContext ctx |
        // 确认在某个上下文中存在指向关系，并记录上下文深度
        PointsTo::points_to(f, ctx, value, cls, _) and
        context_depth = ctx.getDepth()
      )
    ) and
  // 计算指向关系的总大小：包含所有(f, value, cls, ctx, orig)组合
  relation_size =
    strictcount(ControlFlowNode f, Object value, ClassObject cls, PointsToContext ctx,
      ControlFlowNode orig |
      // 验证指向关系并确保包含原始节点信息
      PointsTo::points_to(f, ctx, value, cls, orig) and
      context_depth = ctx.getDepth()
    ) and
  // 计算压缩比率：表示指向关系的压缩效率（百分比形式）
  compression_ratio = 100.0 * fact_count / relation_size
// 输出结果：按上下文深度分组，显示指向事实数量、关系大小和压缩比率
select context_depth, fact_count, relation_size, compression_ratio
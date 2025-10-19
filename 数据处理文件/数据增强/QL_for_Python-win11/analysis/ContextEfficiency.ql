/**
 * 计算指向关系的事实总数、指向关系的总大小以及两者相对于上下文深度的比率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询结果变量：total_facts（事实总数）、total_size（总大小）、depth（上下文深度）和efficiency（效率）
from int total_facts, int total_size, int depth, float efficiency
where
  // 计算指向关系的事实总数，即满足条件的不同(f, value, cls)组合的数量
  total_facts =
    strictcount(ControlFlowNode f, Object value, ClassObject cls |
      exists(PointsToContext ctx |
        // 检查是否存在一个上下文ctx，使得在ctx中f指向value且cls为类对象，并且获取该上下文的深度
        PointsTo::points_to(f, ctx, value, cls, _) and
        depth = ctx.getDepth()
      )
    ) and
  // 计算指向关系的总大小，即满足条件的所有(f, value, cls, ctx, orig)组合的数量
  total_size =
    strictcount(ControlFlowNode f, Object value, ClassObject cls, PointsToContext ctx,
      ControlFlowNode orig |
      // 检查在ctx中f是否指向value且cls为类对象，并且orig是原始节点，同时获取该上下文的深度
      PointsTo::points_to(f, ctx, value, cls, orig) and
      depth = ctx.getDepth()
    ) and
  // 计算效率，即事实总数与总大小的比率，乘以100以表示为百分比
  efficiency = 100.0 * total_facts / total_size
// 选择要显示的结果字段：上下文深度、事实总数、总大小和效率
select depth, total_facts, total_size, efficiency

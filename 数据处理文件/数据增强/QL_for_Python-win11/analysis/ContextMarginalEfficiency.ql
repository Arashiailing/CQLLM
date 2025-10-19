/**
 * 计算边际增加的指向关系事实、指向关系的总大小以及这两者相对于上下文深度的比例。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义一个函数，用于计算给定控制流节点、对象值和类对象的上下文深度。
int depth(ControlFlowNode f, Object value, ClassObject cls) {
  // 存在一个指向上下文ctx，使得在ctx中f指向value且cls为指定类对象，并且结果为ctx的深度。
  exists(PointsToContext ctx |
    PointsTo::points_to(f, ctx, value, cls, _) and
    result = ctx.getDepth()
  )
}

// 定义一个函数，用于计算给定控制流节点、对象值和类对象的最浅深度。
int shallowest(ControlFlowNode f, Object value, ClassObject cls) {
  // 结果为所有可能深度中的最小值。
  result = min(int x | x = depth(f, value, cls))
}

// 从total_facts（总事实数）、total_size（总大小）、depth（深度）和efficiency（效率）中选择数据。
from int total_facts, int total_size, int depth, float efficiency
where
  // 计算总事实数，即满足条件的(f, value, cls)的数量，其中depth为shallowest(f, value, cls)。
  total_facts =
    strictcount(ControlFlowNode f, Object value, ClassObject cls | depth = shallowest(f, value, cls)) and
  // 计算总大小，即满足条件的(f, value, cls, ctx, orig)的数量，其中在ctx中f指向value且cls为指定类对象，并且depth为ctx的深度。
  total_size =
    strictcount(ControlFlowNode f, Object value, ClassObject cls, PointsToContext ctx,
      ControlFlowNode orig |
      PointsTo::points_to(f, ctx, value, cls, orig) and
      depth = ctx.getDepth()
    ) and
  // 计算效率，即总事实数占总大小的比例乘以100。
  efficiency = 100.0 * total_facts / total_size
select depth, total_facts, total_size, efficiency

/**
 * @name Key points-to fails for expression.
 * @description Expression does not "point-to" an object which prevents further points-to analysis.
 * @kind problem
 * @problem.severity info
 * @id py/key-points-to-failure
 * @deprecated
 */

import python
import semmle.python.pointsto.PointsTo

// 定义一个谓词函数，用于判断表达式是否发生了points-to失败
predicate points_to_failure(Expr e) {
  // 存在一个控制流节点f，使得f等于表达式e的流节点，并且不存在从f到任何对象的points-to关系
  exists(ControlFlowNode f | f = e.getAFlowNode() | not PointsTo::pointsTo(f, _, _, _))
}

// 定义另一个谓词函数，用于判断关键表达式是否发生了points-to失败
predicate key_points_to_failure(Expr e) {
  // 表达式e发生了points-to失败
  points_to_failure(e) and
  // 且其子表达式没有发生points-to失败
  not points_to_failure(e.getASubExpression()) and
  // 且不存在使用该表达式流节点的Ssa变量，使得该变量的定义节点也发生了points-to失败
  not exists(SsaVariable ssa | ssa.getAUse() = e.getAFlowNode() |
    points_to_failure(ssa.getAnUltimateDefinition().getDefinition().getNode())
  ) and
  // 且不存在将该表达式作为目标的赋值操作
  not exists(Assign a | a.getATarget() = e)
}

// 查询语句：查找所有满足关键points-to失败条件的表达式，并确保这些表达式不是调用的结果
from Attribute e
where key_points_to_failure(e) and not exists(Call c | c.getFunc() = e)
select e, "Expression does not 'point-to' any object, but all its sources do."

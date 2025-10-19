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

// 定义谓词函数，用于检测表达式是否无法指向任何对象
predicate exprPointsToFailure(Expr targetExpr) {
  // 检查是否存在控制流节点，该节点与表达式关联，但没有任何指向关系
  exists(ControlFlowNode flowNode | 
    flowNode = targetExpr.getAFlowNode() | 
    not PointsTo::pointsTo(flowNode, _, _, _)
  )
}

// 定义谓词函数，用于识别关键的points-to失败表达式
predicate isKeyPointsToFailure(Expr targetExpr) {
  // 确保表达式本身points-to失败
  exprPointsToFailure(targetExpr) and
  // 确保所有子表达式都能正常points-to
  not exprPointsToFailure(targetExpr.getASubExpression()) and
  // 确保没有使用该表达式的SSA变量，其定义节点也points-to失败
  not exists(SsaVariable ssaVar | 
    ssaVar.getAUse() = targetExpr.getAFlowNode() |
    exprPointsToFailure(ssaVar.getAnUltimateDefinition().getDefinition().getNode())
  ) and
  // 确保表达式不是赋值操作的目标
  not exists(Assign assign | assign.getATarget() = targetExpr)
}

// 查询语句：查找所有关键的points-to失败表达式，排除作为函数调用的表达式
from Attribute targetExpr
where isKeyPointsToFailure(targetExpr) and not exists(Call call | call.getFunc() = targetExpr)
select targetExpr, "Expression does not 'point-to' any object, but all its sources do."
/**
 * @name Expression points-to analysis failure.
 * @description Identifies expressions that fail to point-to any object, blocking further points-to analysis.
 * @kind problem
 * @problem.severity info
 * @id py/points-to-analysis-failure
 * @deprecated
 */

import python
import semmle.python.pointsto.PointsTo

// 谓词：检测表达式是否无法指向任何对象
predicate pointsToAnalysisFailed(Expr failedExpr) {
  // 检查表达式关联的控制流节点是否没有任何指向关系
  exists(ControlFlowNode flowNode | 
    flowNode = failedExpr.getAFlowNode() and
    not PointsTo::pointsTo(flowNode, _, _, _)
  )
}

// 谓词：识别关键的points-to失败表达式
predicate isCriticalPointsToFailure(Expr failedExpr) {
  // 基本条件：表达式本身points-to失败
  pointsToAnalysisFailed(failedExpr) and
  // 递归条件：子表达式不会导致points-to失败
  not pointsToAnalysisFailed(failedExpr.getASubExpression()) and
  // SSA变量条件：没有使用该表达式的SSA变量，其定义节点也points-to失败
  not exists(SsaVariable ssaVar | 
    ssaVar.getAUse() = failedExpr.getAFlowNode() and
    pointsToAnalysisFailed(ssaVar.getAnUltimateDefinition().getDefinition().getNode())
  ) and
  // 赋值条件：表达式不是赋值操作的目标
  not exists(Assign assignStmt | assignStmt.getATarget() = failedExpr)
}

// 查询：查找所有关键的points-to失败表达式，排除作为函数调用的表达式
from Attribute failedExpr
where isCriticalPointsToFailure(failedExpr) and not exists(Call callExpr | callExpr.getFunc() = failedExpr)
select failedExpr, "Expression does not 'point-to' any object, but all its sources do."
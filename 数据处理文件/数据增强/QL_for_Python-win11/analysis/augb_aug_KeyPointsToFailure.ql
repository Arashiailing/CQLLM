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

// 定义谓词函数，用于检测表达式是否无法指向任何对象
predicate pointsToAnalysisFailed(Expr problematicExpr) {
  // 检查是否存在控制流节点，该节点与表达式关联，但没有任何指向关系
  exists(ControlFlowNode cfgNode | 
    cfgNode = problematicExpr.getAFlowNode() | 
    not PointsTo::pointsTo(cfgNode, _, _, _)
  )
}

// 定义谓词函数，用于识别关键的points-to失败表达式
predicate isCriticalPointsToFailure(Expr problematicExpr) {
  // 基本条件：表达式本身points-to失败
  pointsToAnalysisFailed(problematicExpr) and
  // 递归条件：所有子表达式都能正常points-to
  not pointsToAnalysisFailed(problematicExpr.getASubExpression()) and
  // SSA变量条件：没有使用该表达式的SSA变量，其定义节点也points-to失败
  not exists(SsaVariable ssaVariable | 
    ssaVariable.getAUse() = problematicExpr.getAFlowNode() |
    pointsToAnalysisFailed(ssaVariable.getAnUltimateDefinition().getDefinition().getNode())
  ) and
  // 赋值条件：表达式不是赋值操作的目标
  not exists(Assign assignment | assignment.getATarget() = problematicExpr)
}

// 查询语句：查找所有关键的points-to失败表达式，排除作为函数调用的表达式
from Attribute problematicExpr
where isCriticalPointsToFailure(problematicExpr) and not exists(Call functionCall | functionCall.getFunc() = problematicExpr)
select problematicExpr, "Expression does not 'point-to' any object, but all its sources do."
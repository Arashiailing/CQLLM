/**
 * @name Key points-to fails for expression.
 * @description Identifies expressions that fail to resolve to any object reference,
 *              which blocks further points-to analysis.
 * @kind problem
 * @problem.severity info
 * @id py/key-points-to-failure
 * @deprecated
 */

import python
import semmle.python.pointsto.PointsTo

// 判断表达式是否无法解析到任何对象引用
predicate points_to_failure(Expr expr) {
  // 检查是否存在控制流节点与该表达式关联，且该节点无法指向任何对象
  exists(ControlFlowNode flowNode | 
    flowNode = expr.getAFlowNode() and 
    not PointsTo::pointsTo(flowNode, _, _, _)
  )
}

// 识别关键的points-to失败表达式，这些表达式本身失败但其子表达式不失败
predicate key_points_to_failure(Expr expr) {
  // 基本条件：表达式本身points-to失败
  points_to_failure(expr) and
  
  // 子表达式必须成功points-to，确保失败点位于当前表达式而非其子表达式
  not points_to_failure(expr.getASubExpression()) and
  
  // 排除因SSA变量定义失败而导致的points-to失败情况
  not exists(SsaVariable ssaVar | 
    ssaVar.getAUse() = expr.getAFlowNode() and
    points_to_failure(ssaVar.getAnUltimateDefinition().getDefinition().getNode())
  ) and
  
  // 确保表达式不是赋值操作的目标，避免误报
  not exists(Assign assign | assign.getATarget() = expr)
}

// 查询所有关键的points-to失败表达式，排除函数调用情况
from Attribute expr
where 
  key_points_to_failure(expr) and 
  not exists(Call call | call.getFunc() = expr)
select expr, "Expression does not 'point-to' any object, but all its sources do."
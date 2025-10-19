/**
 * @name points-to fails for expression.
 * @description Expression does not "point-to" an object which prevents type inference.
 * @kind problem
 * @id py/points-to-failure
 * @problem.severity info
 * @tags debug
 * @deprecated
 */

// 导入Python库，用于处理Python代码的查询和分析
import python

// 从Expr类中选择表达式targetExpr
from Expr targetExpr
// 条件：存在一个控制流节点cfNode，使得cfNode等于targetExpr的控制流节点，并且cfNode不指向任何对象
where exists(ControlFlowNode cfNode | 
    cfNode = targetExpr.getAFlowNode() | 
    not cfNode.refersTo(_)
)
// 选择表达式targetExpr，并返回信息"Expression does not 'point-to' any object."
select targetExpr, "Expression does not 'point-to' any object."
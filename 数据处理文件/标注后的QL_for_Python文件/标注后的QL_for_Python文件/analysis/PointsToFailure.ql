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

// 从Expr类中选择表达式e
from Expr e
// 条件：存在一个控制流节点f，使得f等于e的控制流节点，并且f不指向任何对象
where exists(ControlFlowNode f | f = e.getAFlowNode() | not f.refersTo(_))
// 选择表达式e，并返回信息“Expression does not 'point-to' any object.”
select e, "Expression does not 'point-to' any object."

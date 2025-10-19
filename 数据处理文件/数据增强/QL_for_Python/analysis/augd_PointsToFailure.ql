/**
 * @name points-to fails for expression.
 * @description Expression does not "point-to" an object which prevents type inference.
 * @kind problem
 * @id py/points-to-failure
 * @problem.severity info
 * @tags debug
 * @deprecated
 */

// 导入Python分析库，提供对Python代码的静态分析能力
import python

// 定义：一个表达式如果有控制流节点且该节点不指向任何对象，则符合条件
from Expr expr
where exists(ControlFlowNode flowNode | 
    // 表达式的控制流节点
    flowNode = expr.getAFlowNode() | 
    // 控制流节点不指向任何对象
    not flowNode.refersTo(_)
)
// 输出符合条件的表达式及描述信息
select expr, "Expression does not 'point-to' any object."
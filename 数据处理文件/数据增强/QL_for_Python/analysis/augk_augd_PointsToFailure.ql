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

// 查找所有无法指向任何对象的Python表达式
from Expr targetExpr
where
    // 存在一个与表达式关联的控制流节点不指向任何对象
    exists(ControlFlowNode cfNode | 
        cfNode = targetExpr.getAFlowNode() and
        not cfNode.refersTo(_)
    )
// 输出符合条件的表达式及描述信息
select targetExpr, "Expression does not 'point-to' any object."
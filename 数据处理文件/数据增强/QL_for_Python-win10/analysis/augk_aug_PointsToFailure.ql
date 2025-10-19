/**
 * @name points-to fails for expression.
 * @description Expression does not "point-to" an object which prevents type inference.
 * @kind problem
 * @id py/points-to-failure
 * @problem.severity info
 * @tags debug
 * @deprecated
 */

// 导入Python分析库，提供Python代码的静态分析功能
import python

// 查找所有无法指向任何对象的表达式
from Expr targetExpression
where 
    // 检查表达式是否存在至少一个控制流节点，且该节点没有指向任何对象
    exists(ControlFlowNode associatedFlowNode | 
        // 关联控制流节点与表达式
        associatedFlowNode = targetExpression.getAFlowNode() and 
        // 验证控制流节点未指向任何对象
        not associatedFlowNode.refersTo(_)
    )
// 输出表达式节点及其描述信息
select targetExpression, "Expression does not 'point-to' any object."
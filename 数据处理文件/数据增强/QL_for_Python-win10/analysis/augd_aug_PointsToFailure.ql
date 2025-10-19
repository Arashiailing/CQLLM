/**
 * @name points-to fails for expression.
 * @description Expression does not "point-to" an object which prevents type inference.
 * @kind problem
 * @id py/points-to-failure
 * @problem.severity info
 * @tags debug
 * @deprecated
 */

// 导入Python分析库，提供Python代码的静态分析能力
import python

// 查找所有无法指向任何对象的表达式
from Expr expression
where 
    // 表达式至少有一个控制流节点
    exists(ControlFlowNode controlFlowNode | 
        // 该控制流节点与表达式关联
        controlFlowNode = expression.getAFlowNode() and 
        // 该控制流节点不指向任何对象
        not controlFlowNode.refersTo(_)
    )
// 输出表达式节点及其描述信息
select expression, "Expression does not 'point-to' any object."
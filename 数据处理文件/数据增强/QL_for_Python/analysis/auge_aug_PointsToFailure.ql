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
from Expr expression
where 
    // 检查表达式是否存在至少一个控制流节点，且该节点没有指向任何对象
    // 当表达式无法指向任何对象时，类型推断系统无法确定其类型
    exists(ControlFlowNode controlFlowNode | 
        controlFlowNode = expression.getAFlowNode() and 
        not controlFlowNode.refersTo(_)
    )
// 输出表达式节点及其描述信息
select expression, "Expression does not 'point-to' any object."
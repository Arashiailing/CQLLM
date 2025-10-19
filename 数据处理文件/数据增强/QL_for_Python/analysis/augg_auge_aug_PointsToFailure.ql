/**
 * @name points-to fails for expression.
 * @description Expression does not "point-to" an object which prevents type inference.
 * @kind problem
 * @id py/points-to-failure
 * @problem.severity info
 * @tags debug
 * @deprecated
 */

// 导入Python代码静态分析所需的基础库
import python

// 识别无法指向任何对象的Python表达式，这会影响类型推断系统的正常工作
from Expr problematicExpr
where 
    // 表达式在控制流图中存在节点，且至少有一个节点不引用任何对象
    exists(ControlFlowNode cfgNode | 
        cfgNode = problematicExpr.getAFlowNode() and 
        not cfgNode.refersTo(_)
    )
// 输出问题表达式及其诊断信息
select problematicExpr, "Expression does not 'point-to' any object."
/**
 * @name Nested loops with same variable reused after inner loop body
 * @description Detects when a variable is redefined in an inner loop and then
 *              used in an outer loop, which can lead to unexpected behavior.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/nested-loops-with-same-variable-reused
 */

import python

// 检查循环变量是否在循环语句中被定义
predicate loopVariableDefinition(For loopStmt, Variable iteratedVar, SsaVariable ssaDefinition) {
  // 验证循环目标节点与SSA定义节点匹配，且变量一致
  loopStmt.getTarget().getAFlowNode() = ssaDefinition.getDefinition() and 
  iteratedVar = ssaDefinition.getVariable()
}

// 检测嵌套循环中变量重用情况
predicate nestedLoopVariableReuse(For innerForLoop, For outerForLoop, Variable sharedVar, Name varUsage) {
  /* 内层循环必须位于外层循环的循环体中（排除else子句） */
  outerForLoop.getBody().contains(innerForLoop) and
  /* 变量在外层循环中被使用，但不在内层循环中使用 */
  outerForLoop.contains(varUsage) and
  not innerForLoop.contains(varUsage) and
  /* 验证SSA定义关系：变量在内外层循环中均被定义 */
  exists(SsaVariable innerSsaDef |
    loopVariableDefinition(innerForLoop, sharedVar, innerSsaDef.getAnUltimateDefinition()) and
    loopVariableDefinition(outerForLoop, sharedVar, _) and
    innerSsaDef.getAUse().getNode() = varUsage
  )
}

// 查询满足条件的嵌套循环结构
from For innerForLoop, For outerForLoop, Variable sharedVar, Name varUsage
where nestedLoopVariableReuse(innerForLoop, outerForLoop, sharedVar, varUsage)
select innerForLoop, "Nested for statement $@ loop variable '" + sharedVar.getId() + "' of enclosing $@.", 
       varUsage, "uses", outerForLoop, "for statement"
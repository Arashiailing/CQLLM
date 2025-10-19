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

// 定义一个谓词，用于检查循环变量是否在循环语句中被定义
predicate isLoopVariableDefined(For loopStmt, Variable loopVar, SsaVariable ssaDef) {
  // 验证循环的目标节点是否与SSA变量的定义节点匹配，并且变量v等于SSA变量的变量
  loopStmt.getTarget().getAFlowNode() = ssaDef.getDefinition() and loopVar = ssaDef.getVariable()
}

// 定义一个谓词，用于检测嵌套循环中变量的使用情况
predicate hasVariableReuseInNestedLoops(For innerLoop, For outerLoop, Variable loopVar, Name nameNode) {
  /* 首先确保内层循环位于外层循环的循环体中，而不是else子句中。 */
  outerLoop.getBody().contains(innerLoop) and
  /* 然后检查变量是否在外层循环中使用，但不在内层循环中使用。 */
  outerLoop.contains(nameNode) and
  not innerLoop.contains(nameNode) and
  /* 最后验证SSA定义关系，确保变量在内层和外层循环中都被定义。 */
  exists(SsaVariable ssaDef |
    isLoopVariableDefined(innerLoop, loopVar, ssaDef.getAnUltimateDefinition()) and
    isLoopVariableDefined(outerLoop, loopVar, _) and
    ssaDef.getAUse().getNode() = nameNode
  )
}

// 查询语句，选择满足条件的内层循环、变量名、使用节点以及外层循环
from For innerLoop, For outerLoop, Variable loopVar, Name nameNode
where hasVariableReuseInNestedLoops(innerLoop, outerLoop, loopVar, nameNode)
select innerLoop, "Nested for statement $@ loop variable '" + loopVar.getId() + "' of enclosing $@.", nameNode,
  "uses", outerLoop, "for statement"
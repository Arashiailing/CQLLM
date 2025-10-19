/**
 * @name Nested loops with same variable reused after inner loop body
 * @description Redefining a variable in an inner loop and then using
 *              the variable in an outer loop causes unexpected behavior.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/nested-loops-with-same-variable-reused
 */

import python

// 定义一个谓词，用于判断变量是否在循环中被重新定义
predicate loop_variable_ssa(For f, Variable v, SsaVariable s) {
  // 检查循环的目标节点是否与SSA变量的定义节点相同，并且变量v等于SSA变量的变量
  f.getTarget().getAFlowNode() = s.getDefinition() and v = s.getVariable()
}

// 定义一个谓词，用于判断变量是否在嵌套循环中使用
predicate variableUsedInNestedLoops(For inner, For outer, Variable v, Name n) {
  /* 忽略没有使用变量的情况或仅在内层循环中使用的情况。 */
  outer.contains(n) and
  not inner.contains(n) and
  /* 只处理在循环体中的内层循环。忽略else子句中的循环。 */
  outer.getBody().contains(inner) and
  exists(SsaVariable s |
    // 检查内层循环和外层循环中变量的SSA定义
    loop_variable_ssa(inner, v, s.getAnUltimateDefinition()) and
    loop_variable_ssa(outer, v, _) and
    // 检查变量的使用节点是否为给定的名称节点
    s.getAUse().getNode() = n
  )
}

// 查询语句，选择满足条件的内层循环、变量名、使用节点以及外层循环
from For inner, For outer, Variable v, Name n
where variableUsedInNestedLoops(inner, outer, v, n)
select inner, "Nested for statement $@ loop variable '" + v.getId() + "' of enclosing $@.", n,
  "uses", outer, "for statement"

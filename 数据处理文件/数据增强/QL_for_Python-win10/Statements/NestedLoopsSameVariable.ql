/**
 * @name Nested loops with same variable
 * @description Nested loops in which the target variable is the same for each loop make
 *              the behavior of the loops difficult to understand.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// 定义一个谓词，用于判断给定的循环是否使用了指定的变量作为目标变量。
predicate loop_variable(For f, Variable v) { f.getTarget().defines(v) }

// 定义一个谓词，用于判断内层循环和外层循环是否使用了相同的变量，并且该变量在内层循环中被使用。
predicate variableUsedInNestedLoops(For inner, For outer, Variable v) {
  /* 仅处理在循环体内嵌套的循环。忽略else子句中的循环。 */
  outer.getBody().contains(inner) and
  loop_variable(inner, v) and
  loop_variable(outer, v) and
  /* 忽略没有使用变量的情况或变量仅在内层循环中使用的情况 */
  exists(Name n | n.uses(v) and outer.contains(n) and not inner.contains(n))
}

// 查询语句：查找所有满足条件的内层循环、外层循环和变量，并选择这些元素进行报告。
from For inner, For outer, Variable v
where variableUsedInNestedLoops(inner, outer, v)
select inner, "Nested for statement uses loop variable '" + v.getId() + "' of enclosing $@.", outer,
  "for statement"

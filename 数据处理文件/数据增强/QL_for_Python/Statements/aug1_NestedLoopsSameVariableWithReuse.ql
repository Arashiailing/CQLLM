/**
 * @name Nested loops with same variable reused after inner loop body
 * @description In nested loops, if an inner loop redefines a variable that is also used in the outer loop,
 *              and the variable is used in the outer loop after the inner loop, the behavior may be unexpected.
 *              Specifically, the variable in the outer loop will take the value from the inner loop's last iteration.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/nested-loops-with-same-variable-reused
 */

import python

// 检查循环变量是否与SSA变量定义关联
predicate loop_variable_ssa(For loop, Variable var, SsaVariable ssaVar) {
  // 验证循环目标节点是否匹配SSA变量的定义节点，且变量引用一致
  loop.getTarget().getAFlowNode() = ssaVar.getDefinition() and 
  var = ssaVar.getVariable()
}

// 检测嵌套循环中变量重定义及误用场景
predicate variableUsedInNestedLoops(For innerLoop, For outerLoop, Variable var, Name nameNode) {
  /* 外层循环包含变量使用点，但内层循环不包含（确保使用点在外层作用域） */
  outerLoop.contains(nameNode) and
  not innerLoop.contains(nameNode) and
  /* 内层循环必须位于外层循环体中（排除else子句中的循环） */
  outerLoop.getBody().contains(innerLoop) and
  /* 通过SSA变量追踪变量重定义和使用链 */
  exists(SsaVariable ssaVar |
    // 内层循环重新定义了变量（通过SSA变量的最终定义）
    loop_variable_ssa(innerLoop, var, ssaVar.getAnUltimateDefinition()) and
    // 外层循环也定义了同名变量
    loop_variable_ssa(outerLoop, var, _) and
    // 变量使用点与SSA变量使用节点匹配
    ssaVar.getAUse().getNode() = nameNode
  )
}

// 查询嵌套循环中变量重定义问题
from For innerLoop, For outerLoop, Variable var, Name nameNode
where variableUsedInNestedLoops(innerLoop, outerLoop, var, nameNode)
select innerLoop, 
  "Nested for statement $@ loop variable '" + var.getId() + "' of enclosing $@.", 
  nameNode, "uses", outerLoop, "for statement"
/**
 * @name An assert statement has a side-effect
 * @description This rule identifies assert statements that contain expressions with side-effects.
 *              Such side-effects cause behavioral differences between normal execution and 
 *              optimized builds where assertions are disabled.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/side-effect-in-assert
 */

import python

// 判断表达式是否调用具有副作用的函数
predicate expr_has_side_effect_func(Expr expr) {
  // 检查表达式中的函数名或变量名是否在预定义的副作用函数列表中
  exists(string funcName | 
    funcName = expr.(Attribute).getName() or funcName = expr.(Name).getId() |
    funcName in [
        "print", "write", "append", "pop", "remove", "discard", "delete", "close", "open", "exit"
      ]
  )
}

// 判断调用是否为subprocess模块中的特定函数
predicate is_subprocess_function_call(Call callExpr) {
  // 检查调用节点是否为subprocess.call, subprocess.check_call或subprocess.check_output
  callExpr.getAFlowNode() = Value::named("subprocess.call").getACall()
  or
  callExpr.getAFlowNode() = Value::named("subprocess.check_call").getACall()
  or
  callExpr.getAFlowNode() = Value::named("subprocess.check_output").getACall()
}

// 判断表达式是否可能产生副作用
predicate may_have_side_effect(Expr expr) {
  // 检查是否为显式的yield语句（不包括推导式中的人工yield语句）
  expr instanceof Yield and not exists(Comp comprehension | comprehension.contains(expr))
  or
  // 检查是否为YieldFrom实例
  expr instanceof YieldFrom
  or
  // 检查是否为调用具有副作用的函数
  expr instanceof Call and (
    expr_has_side_effect_func(expr.(Call).getFunc()) or
    is_subprocess_function_call(expr)
  )
}

// 查找包含可能具有副作用表达式的断言语句
from Assert assert_stmt, Expr side_effect_expr
where may_have_side_effect(side_effect_expr) and assert_stmt.contains(side_effect_expr)
select assert_stmt, "This 'assert' statement contains an $@ which may have side effects.", side_effect_expr, "expression"
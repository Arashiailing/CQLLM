/**
 * @name An assert statement has a side-effect
 * @description Detects assert statements containing expressions with side effects,
 *              which can cause behavioral differences between normal and optimized execution.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/side-effect-in-assert
 */

import python

// 判断表达式是否调用具有副作用的内置函数
predicate has_side_effect_function(Expr expression) {
  exists(string funcName | 
    funcName = expression.(Attribute).getName() or funcName = expression.(Name).getId() |
    funcName in [
        "print", "write", "append", "pop", "remove", "discard", "delete", "close", "open", "exit"
      ]
  )
}

// 判断是否调用subprocess模块中的系统命令
predicate is_subprocess_call(Call methodCall) {
  exists(string subprocessFunc | 
    subprocessFunc = "subprocess.call" or 
    subprocessFunc = "subprocess.check_call" or 
    subprocessFunc = "subprocess.check_output" |
    methodCall.getAFlowNode() = Value::named(subprocessFunc).getACall()
  )
}

// 综合判断表达式是否可能产生副作用
predicate may_cause_side_effect(Expr expression) {
  // 检查是否为yield表达式（排除推导式中的伪yield）
  expression instanceof Yield and not exists(Comp c | c.contains(expression))
  or
  // 检查是否为YieldFrom表达式
  expression instanceof YieldFrom
  or
  // 检查是否调用具有副作用的函数
  exists(Call methodCall | 
    methodCall = expression and 
    has_side_effect_function(methodCall.getFunc())
  )
  or
  // 检查是否调用subprocess系统命令
  exists(Call methodCall | 
    methodCall = expression and 
    is_subprocess_call(methodCall)
  )
}

// 查询包含副作用表达式的断言语句
from Assert assertStmt, Expr expression
where may_cause_side_effect(expression) and assertStmt.contains(expression)
select assertStmt, "This 'assert' statement contains an $@ which may have side effects.", expression, "expression"
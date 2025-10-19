/**
 * @name An assert statement has a side-effect
 * @description Side-effects in assert statements result in differences between normal
 *              and optimized behavior.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/side-effect-in-assert
 */

import python

// 检查表达式是否包含已知副作用的内置函数调用
predicate func_with_side_effects(Expr expr) {
  exists(string funcName | 
    funcName = expr.(Attribute).getName() or funcName = expr.(Name).getId() |
    funcName in [
        "print", "write", "append", "pop", "remove", "discard", "delete", "close", "open", "exit"
      ]
  )
}

// 检查调用是否为subprocess模块中的特定系统调用
predicate call_with_side_effect(Call call) {
  exists(string subprocessFunc | 
    subprocessFunc = "subprocess.call" or 
    subprocessFunc = "subprocess.check_call" or 
    subprocessFunc = "subprocess.check_output" |
    call.getAFlowNode() = Value::named(subprocessFunc).getACall()
  )
}

// 综合判断表达式是否可能产生副作用
predicate probable_side_effect(Expr expr) {
  // 显式yield表达式（排除推导式中的伪yield）
  expr instanceof Yield and not exists(Comp c | c.contains(expr))
  or
  // YieldFrom表达式
  expr instanceof YieldFrom
  or
  // 调用已知副作用的内置函数
  exists(Call call | call = expr and func_with_side_effects(call.getFunc()))
  or
  // 调用subprocess系统命令
  exists(Call call | call = expr and call_with_side_effect(call))
}

// 查询包含副作用表达式的断言语句
from Assert assertStmt, Expr expr
where probable_side_effect(expr) and assertStmt.contains(expr)
select assertStmt, "This 'assert' statement contains an $@ which may have side effects.", expr, "expression"
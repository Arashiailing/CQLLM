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

// 检测表达式是否包含具有已知副作用的内置函数调用
predicate builtin_func_with_side_effects(Expr expr) {
  exists(string funcName | 
    funcName = expr.(Attribute).getName() or funcName = expr.(Name).getId() |
    funcName in [
        "print", "write", "append", "pop", "remove", "discard", "delete", "close", "open", "exit"
      ]
  )
}

// 检测调用是否为subprocess模块中的特定系统调用
predicate subprocess_call_with_side_effect(Call callExpr) {
  exists(string subprocessFunc | 
    subprocessFunc = "subprocess.call" or 
    subprocessFunc = "subprocess.check_call" or 
    subprocessFunc = "subprocess.check_output" |
    callExpr.getAFlowNode() = Value::named(subprocessFunc).getACall()
  )
}

// 综合判断表达式是否可能产生副作用
predicate has_potential_side_effect(Expr expr) {
  // 显式yield表达式（排除推导式中的伪yield）
  expr instanceof Yield and not exists(Comp comprehension | comprehension.contains(expr))
  or
  // YieldFrom表达式
  expr instanceof YieldFrom
  or
  // 调用已知副作用的内置函数
  exists(Call callExpr | 
    callExpr = expr and 
    builtin_func_with_side_effects(callExpr.getFunc())
  )
  or
  // 调用subprocess系统命令
  exists(Call callExpr | 
    callExpr = expr and 
    subprocess_call_with_side_effect(callExpr)
  )
}

// 查询包含副作用表达式的断言语句
from Assert stmt, Expr sideEffectExpr
where has_potential_side_effect(sideEffectExpr) and stmt.contains(sideEffectExpr)
select stmt, "This 'assert' statement contains an $@ which may have side effects.", sideEffectExpr, "expression"
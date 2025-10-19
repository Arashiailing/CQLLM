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
predicate has_side_effect_function(Expr expr) {
  exists(string func | 
    func = expr.(Attribute).getName() or func = expr.(Name).getId() |
    func in [
        "print", "write", "append", "pop", "remove", "discard", "delete", "close", "open", "exit"
      ]
  )
}

// 判断是否调用subprocess模块中的系统命令
predicate is_subprocess_call(Call call) {
  exists(string funcName | 
    funcName = "subprocess.call" or 
    funcName = "subprocess.check_call" or 
    funcName = "subprocess.check_output" |
    call.getAFlowNode() = Value::named(funcName).getACall()
  )
}

// 综合判断表达式是否可能产生副作用
predicate may_cause_side_effect(Expr expr) {
  // 检查是否为yield表达式（排除推导式中的伪yield）
  expr instanceof Yield and not exists(Comp c | c.contains(expr))
  or
  // 检查是否为YieldFrom表达式
  expr instanceof YieldFrom
  or
  // 检查是否调用具有副作用的函数或subprocess系统命令
  exists(Call call | 
    call = expr and 
    (has_side_effect_function(call.getFunc()) or is_subprocess_call(call))
  )
}

// 查询包含副作用表达式的断言语句
from Assert assertStmt, Expr expr
where may_cause_side_effect(expr) and assertStmt.contains(expr)
select assertStmt, "This 'assert' statement contains an $@ which may have side effects.", expr, "expression"
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
predicate func_with_side_effects(Expr expression) {
  exists(string functionName | 
    (functionName = expression.(Attribute).getName() or functionName = expression.(Name).getId()) and
    functionName in [
        "print", "write", "append", "pop", "remove", "discard", "delete", "close", "open", "exit"
      ]
  )
}

// 检查调用是否为subprocess模块中的特定系统调用
predicate call_with_side_effect(Call functionCall) {
  exists(string subprocessFunction | 
    (subprocessFunction = "subprocess.call" or 
     subprocessFunction = "subprocess.check_call" or 
     subprocessFunction = "subprocess.check_output") and
    functionCall.getAFlowNode() = Value::named(subprocessFunction).getACall()
  )
}

// 综合判断表达式是否可能产生副作用
predicate probable_side_effect(Expr expression) {
  // 显式yield表达式（排除推导式中的伪yield）
  (expression instanceof Yield and not exists(Comp c | c.contains(expression)))
  or
  // YieldFrom表达式
  expression instanceof YieldFrom
  or
  // 调用已知副作用的内置函数
  exists(Call functionCall | 
    functionCall = expression and 
    func_with_side_effects(functionCall.getFunc())
  )
  or
  // 调用subprocess系统命令
  exists(Call functionCall | 
    functionCall = expression and 
    call_with_side_effect(functionCall)
  )
}

// 查询包含副作用表达式的断言语句
from Assert assertStatement, Expr expression
where probable_side_effect(expression) and assertStatement.contains(expression)
select assertStatement, "This 'assert' statement contains an $@ which may have side effects.", expression, "expression"
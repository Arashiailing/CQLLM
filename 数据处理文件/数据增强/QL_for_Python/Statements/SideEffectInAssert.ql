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

// 定义一个谓词函数，用于判断表达式是否包含具有副作用的函数调用
predicate func_with_side_effects(Expr e) {
  // 检查表达式中的函数名或变量名是否在指定的具有副作用的函数名列表中
  exists(string name | name = e.(Attribute).getName() or name = e.(Name).getId() |
    name in [
        "print", "write", "append", "pop", "remove", "discard", "delete", "close", "open", "exit"
      ]
  )
}

// 定义一个谓词函数，用于判断调用是否为特定的subprocess模块中的函数
predicate call_with_side_effect(Call e) {
  // 检查调用节点是否为subprocess.call, subprocess.check_call或subprocess.check_output
  e.getAFlowNode() = Value::named("subprocess.call").getACall()
  or
  e.getAFlowNode() = Value::named("subprocess.check_call").getACall()
  or
  e.getAFlowNode() = Value::named("subprocess.check_output").getACall()
}

// 定义一个谓词函数，用于判断表达式是否可能具有副作用
predicate probable_side_effect(Expr e) {
  // 仅考虑显式的yield语句，不包括理解中的人工yield语句
  e instanceof Yield and not exists(Comp c | c.contains(e))
  or
  // 检查是否为YieldFrom实例
  e instanceof YieldFrom
  or
  // 检查是否为调用具有副作用的函数
  e instanceof Call and func_with_side_effects(e.(Call).getFunc())
  or
  // 检查是否为特定的subprocess模块中的函数调用
  e instanceof Call and call_with_side_effect(e)
}

// 从Assert和Expr中选择数据，并应用条件过滤
from Assert a, Expr e
where probable_side_effect(e) and a.contains(e)
select a, "This 'assert' statement contains an $@ which may have side effects.", e, "expression"

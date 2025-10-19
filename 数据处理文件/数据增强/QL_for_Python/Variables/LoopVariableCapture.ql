/**
 * @name Loop variable capture
 * @description Capture of a loop variable is not the same as capturing the value of a loop variable, and may be erroneous.
 * @kind problem
 * @tags correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/loop-variable-capture
 */

import python

// 获取循环作用域的迭代变量的作用域
Scope iteration_variable_scope(AstNode loop) {
  result = loop.(For).getScope() // 如果节点是 For 循环，则获取其作用域
  or
  result = loop.(Comp).getFunction() // 如果节点是 Comprehension（推导式），则获取其函数
}

// 判断是否捕获了循环构造中的变量
predicate capturing_looping_construct(CallableExpr capturing, AstNode loop, Variable var) {
  var.getScope() = iteration_variable_scope(loop) and // 变量的作用域与循环迭代变量的作用域相同
  var.getAnAccess().getScope() = capturing.getInnerScope() and // 变量的访问作用域与捕获表达式的内部作用域相同
  capturing.getParentNode+() = loop and // 捕获表达式的父节点是循环节点
  (
    loop.(For).getTarget() = var.getAnAccess() // 如果循环是 For 循环，且目标变量是该变量
    or
    var = loop.(Comp).getAnIterationVariable() // 如果循环是 Comprehension，且变量是迭代变量
  )
}

// 判断是否逃逸了捕获的循环构造中的变量
predicate escaping_capturing_looping_construct(CallableExpr capturing, AstNode loop, Variable var) {
  capturing_looping_construct(capturing, loop, var) and // 满足捕获循环构造的条件
  // 如果变量在 for 循环外使用或是 comprehension 中的 lambda 表达式，则认为逃逸
  (
    loop instanceof For and // 如果循环是 For 循环
    exists(Expr e | e.pointsTo(_, _, capturing) | not loop.contains(e)) // 存在指向捕获表达式的表达式，并且不在循环内
    or
    loop.(Comp).getElt() = capturing // 如果循环是 Comprehension，且元素是捕获表达式
    or
    loop.(Comp).getElt().(Tuple).getAnElt() = capturing // 如果循环是 Comprehension，且元组中的元素是捕获表达式
  )
}

// 查询捕获并逃逸的循环变量
from CallableExpr capturing, AstNode loop, Variable var
where escaping_capturing_looping_construct(capturing, loop, var) // 条件：逃逸了捕获的循环构造中的变量
select capturing, "Capture of loop variable $@.", loop, var.getId() // 选择捕获表达式、提示信息、循环节点和变量 ID

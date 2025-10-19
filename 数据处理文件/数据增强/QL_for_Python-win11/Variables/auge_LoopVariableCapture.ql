/**
 * @name Loop variable capture
 * @description Detects when a loop variable is captured in a closure or comprehension,
 *              which can lead to unexpected behavior as the variable's value may change
 *              after the closure is created.
 * @kind problem
 * @tags correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/loop-variable-capture
 */

import python

// 获取循环迭代变量的作用域范围
Scope getLoopIterationVariableScope(AstNode loopNode) {
  result = loopNode.(For).getScope() // 对于For循环，返回其作用域
  or
  result = loopNode.(Comp).getFunction() // 对于推导式，返回其所属函数
}

// 检查表达式是否捕获了循环变量
predicate isCapturingLoopVariable(CallableExpr capturingExpr, AstNode loopNode, Variable loopVar) {
  loopVar.getScope() = getLoopIterationVariableScope(loopNode) and // 变量作用域与循环迭代变量作用域匹配
  loopVar.getAnAccess().getScope() = capturingExpr.getInnerScope() and // 变量访问位于捕获表达式的内部作用域
  capturingExpr.getParentNode+() = loopNode and // 捕获表达式是循环节点的后代
  (
    loopNode.(For).getTarget() = loopVar.getAnAccess() // For循环的目标变量是当前变量
    or
    loopVar = loopNode.(Comp).getAnIterationVariable() // 推导式中的迭代变量是当前变量
  )
}

// 检查捕获的循环变量是否逃逸了原始作用域
predicate isEscapingCapturedLoopVariable(CallableExpr capturingExpr, AstNode loopNode, Variable loopVar) {
  isCapturingLoopVariable(capturingExpr, loopNode, loopVar) and // 确认捕获了循环变量
  (
    // For循环中的变量逃逸情况
    loopNode instanceof For and
    exists(Expr refExpr | 
      refExpr.pointsTo(_, _, capturingExpr) and // 存在指向捕获表达式的引用
      not loopNode.contains(refExpr) // 引用位于循环外部
    )
    or
    // 推导式中的变量逃逸情况
    loopNode.(Comp).getElt() = capturingExpr // 推导式的元素是捕获表达式
    or
    loopNode.(Comp).getElt().(Tuple).getAnElt() = capturingExpr // 推导式元素是元组，且元组包含捕获表达式
  )
}

// 查询所有捕获并逃逸的循环变量
from CallableExpr capturingExpr, AstNode loopNode, Variable loopVar
where isEscapingCapturedLoopVariable(capturingExpr, loopNode, loopVar)
select capturingExpr, "Capture of loop variable $@.", loopNode, loopVar.getId()
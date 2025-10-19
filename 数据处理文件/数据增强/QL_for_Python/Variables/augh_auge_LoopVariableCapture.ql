/**
 * @name Loop variable capture
 * @description 检测循环变量在闭包或推导式中被捕获的情况。
 *              这可能导致意外行为，因为闭包创建后，循环变量的值可能会改变。
 * @kind problem
 * @tags correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/loop-variable-capture
 */

import python

// 获取循环迭代变量所属的作用域
Scope getLoopIterationVariableScope(AstNode loopNode) {
  result = loopNode.(For).getScope()  // For循环的直接作用域
  or
  result = loopNode.(Comp).getFunction()  // 推导式所属的函数作用域
}

// 判断表达式是否捕获了循环变量
predicate isCapturingLoopVariable(CallableExpr capturedExpr, AstNode loopNode, Variable loopVar) {
  // 确保变量属于循环迭代作用域
  loopVar.getScope() = getLoopIterationVariableScope(loopNode) and
  // 变量访问发生在捕获表达式的内部作用域
  loopVar.getAnAccess().getScope() = capturedExpr.getInnerScope() and
  // 捕获表达式是循环节点的后代
  capturedExpr.getParentNode+() = loopNode and
  (
    // For循环：目标变量是当前变量
    loopNode.(For).getTarget() = loopVar.getAnAccess()
    or
    // 推导式：迭代变量是当前变量
    loopVar = loopNode.(Comp).getAnIterationVariable()
  )
}

// 判断捕获的循环变量是否逃逸了原始作用域
predicate isEscapingCapturedLoopVariable(CallableExpr capturedExpr, AstNode loopNode, Variable loopVar) {
  isCapturingLoopVariable(capturedExpr, loopNode, loopVar) and
  (
    // For循环中的逃逸情况：存在循环外部的引用
    loopNode instanceof For and
    exists(Expr refExpr | 
      refExpr.pointsTo(_, _, capturedExpr) and
      not loopNode.contains(refExpr)
    )
    or
    // 推导式中的逃逸情况：捕获表达式作为元素或元素的一部分
    loopNode.(Comp).getElt() = capturedExpr
    or
    loopNode.(Comp).getElt().(Tuple).getAnElt() = capturedExpr
  )
}

// 查询所有捕获并逃逸的循环变量
from CallableExpr capturedExpr, AstNode loopNode, Variable loopVar
where isEscapingCapturedLoopVariable(capturedExpr, loopNode, loopVar)
select capturedExpr, "Capture of loop variable $@.", loopNode, loopVar.getId()
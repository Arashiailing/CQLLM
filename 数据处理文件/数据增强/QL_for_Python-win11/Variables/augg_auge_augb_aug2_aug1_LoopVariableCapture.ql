/**
 * @name Loop variable capture
 * @description Identifies loop iteration variables captured by reference instead of value,
 *              potentially causing unexpected behavior when accessed after loop completion.
 * @kind problem
 * @tags correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/loop-variable-capture
 */

import python

// Resolve iteration variable scope for different loop constructs
Scope getIterationVariableScope(AstNode loopNode) {
  // Handle standard for-loops: return local scope
  result = loopNode.(For).getScope()
  or
  // Handle comprehensions: return enclosing function's scope
  result = loopNode.(Comp).getFunction()
}

// Detect captured loop variables that escape their intended context
predicate capturedLoopVariableEscapes(CallableExpr capturedFuncExpr, AstNode loopNode, Variable loopIterVar) {
  // Verify variable belongs to loop iteration scope
  loopIterVar.getScope() = getIterationVariableScope(loopNode) and
  // Confirm variable access occurs within captured callable's scope
  loopIterVar.getAnAccess().getScope() = capturedFuncExpr.getInnerScope() and
  // Ensure callable is nested inside loop structure
  capturedFuncExpr.getParentNode+() = loopNode and
  // Validate variable is an iteration variable of the loop
  (
    // For-loop iteration variable case
    loopNode.(For).getTarget() = loopIterVar.getAnAccess()
    or
    // Comprehension iteration variable case
    loopIterVar = loopNode.(Comp).getAnIterationVariable()
  ) and
  // Check escape conditions based on loop type
  (
    // For-loop escape: variable referenced outside loop body
    loopNode instanceof For and
    exists(Expr escapingRef | 
      escapingRef.pointsTo(_, _, capturedFuncExpr) and 
      not loopNode.contains(escapingRef)
    )
    or
    // Comprehension escape: variable captured as element or tuple element
    loopNode.(Comp).getElt() = capturedFuncExpr
    or
    loopNode.(Comp).getElt().(Tuple).getAnElt() = capturedFuncExpr
  )
}

// Identify all instances where loop variables are captured and escape context
from CallableExpr capturedFuncExpr, AstNode loopNode, Variable loopIterVar
where capturedLoopVariableEscapes(capturedFuncExpr, loopNode, loopIterVar)
select capturedFuncExpr, "Capture of loop variable $@.", loopNode, loopIterVar.getId()
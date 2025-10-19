/**
 * @name Loop variable capture
 * @description Capturing a loop variable instead of its value can lead to unexpected behavior.
 *              This occurs when a variable from a loop construct is referenced after the loop iteration.
 * @kind problem
 * @tags correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/loop-variable-capture
 */

import python

// Determine the scope of iteration variables for different loop constructs
Scope iteration_variable_scope(AstNode loopNode) {
  result = loopNode.(For).getScope()  // Scope for for-loops
  or
  result = loopNode.(Comp).getFunction()  // Scope for comprehensions
}

// Identify cases where a loop variable is captured by a callable expression
predicate capturing_looping_construct(CallableExpr capturedExpr, AstNode loopNode, Variable loopVar) {
  // The variable must be in the loop's iteration scope
  loopVar.getScope() = iteration_variable_scope(loopNode) and
  // Variable access occurs within the captured expression's scope
  loopVar.getAnAccess().getScope() = capturedExpr.getInnerScope() and
  // Captured expression is nested inside the loop construct
  capturedExpr.getParentNode+() = loopNode and
  // Verify the variable is an actual iteration variable of the loop
  (
    loopNode.(For).getTarget() = loopVar.getAnAccess()  // For-loop target
    or
    loopVar = loopNode.(Comp).getAnIterationVariable()  // Comprehension iterator
  )
}

// Detect when captured loop variables escape their original context
predicate escaping_capturing_looping_construct(CallableExpr capturedExpr, AstNode loopNode, Variable loopVar) {
  capturing_looping_construct(capturedExpr, loopNode, loopVar) and
  // Check for escape conditions based on loop type
  (
    // For-loop escape: variable referenced outside loop
    loopNode instanceof For and
    exists(Expr refExpr | 
      refExpr.pointsTo(_, _, capturedExpr) and 
      not loopNode.contains(refExpr)
    )
    or
    // Comprehension escape: captured as element or tuple element
    loopNode.(Comp).getElt() = capturedExpr
    or
    loopNode.(Comp).getElt().(Tuple).getAnElt() = capturedExpr
  )
}

// Find all instances where loop variables are captured and escape their context
from CallableExpr capturedExpr, AstNode loopNode, Variable loopVar
where escaping_capturing_looping_construct(capturedExpr, loopNode, loopVar)
select capturedExpr, "Capture of loop variable $@.", loopNode, loopVar.getId()
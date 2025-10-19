/**
 * @name Loop variable capture
 * @description Identifies when loop iteration variables are captured by reference instead of value,
 *              potentially causing unexpected behavior when accessed after loop completion.
 * @kind problem
 * @tags correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/loop-variable-capture
 */

import python

// Determine the appropriate scope for iteration variables in different loop constructs
Scope retrieveIterationVarScope(AstNode loopNode) {
  // Handle standard for-loops by returning their local scope
  result = loopNode.(For).getScope()
  or
  // Handle comprehensions by returning their containing function's scope
  result = loopNode.(Comp).getFunction()
}

// Detect cases where loop iteration variables are captured within callable expressions
predicate hasLoopVarCapturedInCallable(CallableExpr capturedFn, AstNode loopNode, Variable loopVar) {
  // Verify the variable belongs to the loop's iteration scope
  loopVar.getScope() = retrieveIterationVarScope(loopNode) and
  // Confirm variable access occurs inside the captured callable's scope
  loopVar.getAnAccess().getScope() = capturedFn.getInnerScope() and
  // Ensure the callable is nested within the loop structure
  capturedFn.getParentNode+() = loopNode and
  // Validate the variable is an iteration variable of the loop
  (
    // For-loop iteration variable case
    loopNode.(For).getTarget() = loopVar.getAnAccess()
    or
    // Comprehension iteration variable case
    loopVar = loopNode.(Comp).getAnIterationVariable()
  )
}

// Identify when captured loop variables are referenced outside their intended context
predicate capturedLoopVarEscapes(CallableExpr capturedFn, AstNode loopNode, Variable loopVar) {
  hasLoopVarCapturedInCallable(capturedFn, loopNode, loopVar) and
  // Check escape conditions based on loop construct type
  (
    // For-loop escape: variable referenced outside loop body
    loopNode instanceof For and
    exists(Expr externalRef | 
      externalRef.pointsTo(_, _, capturedFn) and 
      not loopNode.contains(externalRef)
    )
    or
    // Comprehension escape: variable captured as element or tuple element
    loopNode.(Comp).getElt() = capturedFn
    or
    loopNode.(Comp).getElt().(Tuple).getAnElt() = capturedFn
  )
}

// Query to find all instances where loop variables are captured and escape their original context
from CallableExpr capturedFn, AstNode loopNode, Variable loopVar
where capturedLoopVarEscapes(capturedFn, loopNode, loopVar)
select capturedFn, "Capture of loop variable $@.", loopNode, loopVar.getId()
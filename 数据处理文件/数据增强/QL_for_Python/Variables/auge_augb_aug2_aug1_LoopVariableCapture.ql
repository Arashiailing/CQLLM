/**
 * @name Loop variable capture
 * @description Detects loop iteration variables captured by reference rather than value,
 *              which may lead to unexpected behavior when accessed after loop execution.
 * @kind problem
 * @tags correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/loop-variable-capture
 */

import python

// Determine the appropriate scope for iteration variables across different loop types
Scope getIterationVariableScope(AstNode loopConstruct) {
  // Handle standard for-loops by returning their local scope
  result = loopConstruct.(For).getScope()
  or
  // Handle comprehensions by returning their enclosing function's scope
  result = loopConstruct.(Comp).getFunction()
}

// Identify cases where loop iteration variables are captured within callable expressions
predicate loopVariableCapturedInCallable(CallableExpr capturedCallable, AstNode loopConstruct, Variable iterationVar) {
  // Ensure variable belongs to loop's iteration scope
  iterationVar.getScope() = getIterationVariableScope(loopConstruct) and
  // Verify variable access occurs inside captured callable's scope
  iterationVar.getAnAccess().getScope() = capturedCallable.getInnerScope() and
  // Confirm callable is nested within loop structure
  capturedCallable.getParentNode+() = loopConstruct and
  // Validate variable is an iteration variable of the loop
  (
    // For-loop iteration variable case
    loopConstruct.(For).getTarget() = iterationVar.getAnAccess()
    or
    // Comprehension iteration variable case
    iterationVar = loopConstruct.(Comp).getAnIterationVariable()
  )
}

// Detect when captured loop variables are referenced outside their intended context
predicate capturedLoopVariableEscapes(CallableExpr capturedCallable, AstNode loopConstruct, Variable iterationVar) {
  loopVariableCapturedInCallable(capturedCallable, loopConstruct, iterationVar) and
  // Check escape conditions based on loop construct type
  (
    // For-loop escape: variable referenced outside loop body
    loopConstruct instanceof For and
    exists(Expr externalReference | 
      externalReference.pointsTo(_, _, capturedCallable) and 
      not loopConstruct.contains(externalReference)
    )
    or
    // Comprehension escape: variable captured as element or tuple element
    loopConstruct.(Comp).getElt() = capturedCallable
    or
    loopConstruct.(Comp).getElt().(Tuple).getAnElt() = capturedCallable
  )
}

// Find all instances where loop variables are captured and escape their original context
from CallableExpr capturedCallable, AstNode loopConstruct, Variable iterationVar
where capturedLoopVariableEscapes(capturedCallable, loopConstruct, iterationVar)
select capturedCallable, "Capture of loop variable $@.", loopConstruct, iterationVar.getId()
/**
 * @name Loop variable capture
 * @description Detects when a loop variable is captured by reference instead of value,
 *              which can cause unexpected behavior when the variable is accessed after
 *              the loop iteration has completed.
 * @kind problem
 * @tags correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/loop-variable-capture
 */

import python

// Define the scope context for iteration variables across different loop types
Scope getIterationVariableScope(AstNode loopConstruct) {
  // For standard for-loops, return the loop's local scope
  result = loopConstruct.(For).getScope()
  or
  // For comprehensions, return the containing function's scope
  result = loopConstruct.(Comp).getFunction()
}

// Identify scenarios where a loop iteration variable is captured within a callable expression
predicate loopVariableCapturedInCallable(CallableExpr capturedCallable, AstNode loopConstruct, Variable iterationVar) {
  // Ensure the variable belongs to the loop's iteration scope
  iterationVar.getScope() = getIterationVariableScope(loopConstruct) and
  // Confirm variable access occurs inside the captured callable's scope
  iterationVar.getAnAccess().getScope() = capturedCallable.getInnerScope() and
  // Verify the callable is nested within the loop structure
  capturedCallable.getParentNode+() = loopConstruct and
  // Validate the variable is indeed an iteration variable of the loop
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
  // Check escape conditions based on the type of loop construct
  (
    // For-loop escape: variable is referenced outside the loop body
    loopConstruct instanceof For and
    exists(Expr externalReference | 
      externalReference.pointsTo(_, _, capturedCallable) and 
      not loopConstruct.contains(externalReference)
    )
    or
    // Comprehension escape: variable is captured as an element or tuple element
    loopConstruct.(Comp).getElt() = capturedCallable
    or
    loopConstruct.(Comp).getElt().(Tuple).getAnElt() = capturedCallable
  )
}

// Query to find all instances where loop variables are captured and escape their original context
from CallableExpr capturedCallable, AstNode loopConstruct, Variable iterationVar
where capturedLoopVariableEscapes(capturedCallable, loopConstruct, iterationVar)
select capturedCallable, "Capture of loop variable $@.", loopConstruct, iterationVar.getId()
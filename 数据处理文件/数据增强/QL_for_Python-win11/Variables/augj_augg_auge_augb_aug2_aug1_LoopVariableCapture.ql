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

// Determine the appropriate scope for loop iteration variables
Scope resolveIterationVariableScope(AstNode loopConstruct) {
  // For standard for-loops: return the loop's local scope
  result = loopConstruct.(For).getScope()
  or
  // For comprehensions: return the enclosing function's scope
  result = loopConstruct.(Comp).getFunction()
}

// Identify loop variables captured by callables that escape their intended context
predicate loopVariableCaptureEscapes(CallableExpr capturedCallable, AstNode loopConstruct, Variable iterationVar) {
  // Ensure the variable belongs to the loop's iteration scope
  iterationVar.getScope() = resolveIterationVariableScope(loopConstruct) and
  // Verify variable access occurs within the captured callable's scope
  iterationVar.getAnAccess().getScope() = capturedCallable.getInnerScope() and
  // Confirm the callable is nested inside the loop structure
  capturedCallable.getParentNode+() = loopConstruct and
  // Validate the variable is an iteration variable of the loop
  (
    // Case 1: For-loop iteration variable
    loopConstruct.(For).getTarget() = iterationVar.getAnAccess()
    or
    // Case 2: Comprehension iteration variable
    iterationVar = loopConstruct.(Comp).getAnIterationVariable()
  ) and
  // Check escape conditions based on loop type
  (
    // For-loop escape: variable referenced outside loop body
    loopConstruct instanceof For and
    exists(Expr escapingReference | 
      escapingReference.pointsTo(_, _, capturedCallable) and 
      not loopConstruct.contains(escapingReference)
    )
    or
    // Comprehension escape: variable captured as element or tuple element
    loopConstruct.(Comp).getElt() = capturedCallable
    or
    loopConstruct.(Comp).getElt().(Tuple).getAnElt() = capturedCallable
  )
}

// Find all instances where loop variables are improperly captured and escape context
from CallableExpr capturedCallable, AstNode loopConstruct, Variable iterationVar
where loopVariableCaptureEscapes(capturedCallable, loopConstruct, iterationVar)
select capturedCallable, "Capture of loop variable $@.", loopConstruct, iterationVar.getId()
/**
 * @name Loop variable capture
 * @description Detects when loop iteration variables are captured by reference rather than by value,
 *              which can lead to unexpected behavior when these variables are accessed after the loop completes.
 * @kind problem
 * @tags correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/loop-variable-capture
 */

import python

// Retrieve the appropriate scope for iteration variables in different loop constructs
Scope getIterationVariableScope(AstNode loopConstruct) {
  // Handle standard for-loops by returning their local scope
  result = loopConstruct.(For).getScope()
  or
  // Handle comprehensions by returning their containing function's scope
  result = loopConstruct.(Comp).getFunction()
}

// Check if loop iteration variables are captured within callable expressions
predicate isLoopVariableCapturedInCallable(CallableExpr callableExpression, AstNode loopConstruct, Variable iterationVariable) {
  // Ensure the variable belongs to the loop's iteration scope
  iterationVariable.getScope() = getIterationVariableScope(loopConstruct) and
  // Verify that variable access occurs inside the captured callable's scope
  iterationVariable.getAnAccess().getScope() = callableExpression.getInnerScope() and
  // Confirm the callable is nested within the loop structure
  callableExpression.getParentNode+() = loopConstruct and
  // Validate the variable is an iteration variable of the loop
  (
    // For-loop iteration variable case
    loopConstruct.(For).getTarget() = iterationVariable.getAnAccess()
    or
    // Comprehension iteration variable case
    iterationVariable = loopConstruct.(Comp).getAnIterationVariable()
  )
}

// Identify when captured loop variables are referenced outside their intended context
predicate doesCapturedLoopVariableEscape(CallableExpr callableExpression, AstNode loopConstruct, Variable iterationVariable) {
  isLoopVariableCapturedInCallable(callableExpression, loopConstruct, iterationVariable) and
  // Check escape conditions based on loop construct type
  (
    // For-loop escape: variable referenced outside loop body
    loopConstruct instanceof For and
    exists(Expr externalReference | 
      externalReference.pointsTo(_, _, callableExpression) and 
      not loopConstruct.contains(externalReference)
    )
    or
    // Comprehension escape: variable captured as element or tuple element
    loopConstruct.(Comp).getElt() = callableExpression
    or
    loopConstruct.(Comp).getElt().(Tuple).getAnElt() = callableExpression
  )
}

// Query to find all instances where loop variables are captured and escape their original context
from CallableExpr callableExpression, AstNode loopConstruct, Variable iterationVariable
where doesCapturedLoopVariableEscape(callableExpression, loopConstruct, iterationVariable)
select callableExpression, "Capture of loop variable $@.", loopConstruct, iterationVariable.getId()
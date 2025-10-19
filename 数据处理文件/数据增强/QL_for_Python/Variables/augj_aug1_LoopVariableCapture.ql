/**
 * @name Loop Variable Capture Issue
 * @description Detects when a loop variable is captured by reference rather than by value,
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

// Retrieves the appropriate scope for iteration variables based on the loop construct type
Scope getIterationVariableScope(AstNode loopConstruct) {
  result = loopConstruct.(For).getScope()  // For-loops use their own scope
  or
  result = loopConstruct.(Comp).getFunction()  // Comprehensions use the function's scope
}

// Identifies when a loop variable is being captured within a callable expression
predicate isLoopVariableCaptured(CallableExpr capturingExpression, AstNode loopConstruct, Variable iterationVariable) {
  // Ensure the variable belongs to the loop's iteration scope
  iterationVariable.getScope() = getIterationVariableScope(loopConstruct) and
  // Check that the variable is accessed within the captured expression's scope
  iterationVariable.getAnAccess().getScope() = capturingExpression.getInnerScope() and
  // Verify the expression is nested inside the loop construct
  capturingExpression.getParentNode+() = loopConstruct and
  // Confirm the variable is indeed an iteration variable of the loop
  (
    loopConstruct.(For).getTarget() = iterationVariable.getAnAccess()  // For-loop iteration variable
    or
    iterationVariable = loopConstruct.(Comp).getAnIterationVariable()  // Comprehension iteration variable
  )
}

// Detects when a captured loop variable escapes its original context
predicate doesCapturedVariableEscape(CallableExpr capturingExpression, AstNode loopConstruct, Variable iterationVariable) {
  isLoopVariableCaptured(capturingExpression, loopConstruct, iterationVariable) and
  // Different escape conditions based on the type of loop construct
  (
    // For-loop escape: variable is referenced outside the loop
    loopConstruct instanceof For and
    exists(Expr referenceExpression | 
      referenceExpression.pointsTo(_, _, capturingExpression) and 
      not loopConstruct.contains(referenceExpression)
    )
    or
    // Comprehension escape: variable is captured as an element or tuple element
    loopConstruct.(Comp).getElt() = capturingExpression
    or
    loopConstruct.(Comp).getElt().(Tuple).getAnElt() = capturingExpression
  )
}

// Main query: Find all instances where loop variables are captured and escape their context
from CallableExpr capturingExpression, AstNode loopConstruct, Variable iterationVariable
where doesCapturedVariableEscape(capturingExpression, loopConstruct, iterationVariable)
select capturingExpression, "Capture of loop variable $@.", loopConstruct, iterationVariable.getId()
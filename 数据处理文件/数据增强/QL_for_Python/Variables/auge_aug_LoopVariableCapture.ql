/**
 * @name Loop variable capture
 * @description Detects when loop variables are captured in closures instead of their values, which may lead to unexpected behavior.
 * @kind problem
 * @tags correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/loop-variable-capture
 */

import python

/**
 * Retrieves the scope containing iteration variables for the specified loop construct.
 * For For-loops, returns the loop's own scope.
 * For comprehensions, returns the containing function's scope.
 */
Scope getIterationScope(AstNode loopConstruct) {
  result = loopConstruct.(For).getScope()
  or
  result = loopConstruct.(Comp).getFunction()
}

/**
 * Determines if a callable expression captures a loop variable within its iteration scope.
 * Conditions:
 * 1. Variable is defined in the loop's iteration scope
 * 2. Variable is accessed within the callable's inner scope
 * 3. Callable is nested inside the loop construct
 * 4. Variable is either a For-loop target or comprehension iteration variable
 */
predicate capturesLoopVariable(CallableExpr capturedCallable, AstNode loopConstruct, Variable iterationVariable) {
  iterationVariable.getScope() = getIterationScope(loopConstruct) and
  iterationVariable.getAnAccess().getScope() = capturedCallable.getInnerScope() and
  capturedCallable.getParentNode+() = loopConstruct and
  (
    loopConstruct.(For).getTarget() = iterationVariable.getAnAccess()
    or
    iterationVariable = loopConstruct.(Comp).getAnIterationVariable()
  )
}

/**
 * Determines if the captured loop variable escapes its original loop construct.
 * Escape conditions:
 * 1. For-loops: Reference exists outside the loop body
 * 2. Comprehensions: Callable is used as the element or in a tuple element
 */
predicate escapesLoopCapture(CallableExpr capturedCallable, AstNode loopConstruct, Variable iterationVariable) {
  capturesLoopVariable(capturedCallable, loopConstruct, iterationVariable) and
  (
    loopConstruct instanceof For and
    exists(Expr reference | reference.pointsTo(_, _, capturedCallable) | not loopConstruct.contains(reference))
    or
    loopConstruct.(Comp).getElt() = capturedCallable
    or
    loopConstruct.(Comp).getElt().(Tuple).getAnElt() = capturedCallable
  )
}

// Identify callable expressions that capture and escape loop variables
from CallableExpr capturedCallable, AstNode loopConstruct, Variable iterationVariable
where escapesLoopCapture(capturedCallable, loopConstruct, iterationVariable)
select capturedCallable, "Capture of loop variable $@.", loopConstruct, iterationVariable.getId()
/**
 * @name Loop variable capture
 * @description Capture of a loop variable is not the same as capturing the value of a loop variable, and may be erroneous.
 * @kind problem
 * @tags correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/loop-variable-capture
 */

import python

/**
 * Gets the scope containing iteration variables for the given loop construct.
 * For For-loops, returns the loop's own scope.
 * For comprehensions, returns the containing function's scope.
 */
Scope getIterationScope(AstNode loopNode) {
  result = loopNode.(For).getScope()
  or
  result = loopNode.(Comp).getFunction()
}

/**
 * Holds if the callable expression captures a loop variable within its iteration scope.
 * Requires:
 * 1. Variable is defined in the loop's iteration scope
 * 2. Variable is accessed within the callable's inner scope
 * 3. Callable is nested inside the loop construct
 * 4. Variable is either a For-loop target or comprehension iteration variable
 */
predicate capturesLoopVariable(CallableExpr callable, AstNode loopNode, Variable loopVar) {
  loopVar.getScope() = getIterationScope(loopNode) and
  loopVar.getAnAccess().getScope() = callable.getInnerScope() and
  callable.getParentNode+() = loopNode and
  (
    loopNode.(For).getTarget() = loopVar.getAnAccess()
    or
    loopVar = loopNode.(Comp).getAnIterationVariable()
  )
}

/**
 * Holds if the captured loop variable escapes its original loop construct.
 * Escape occurs when:
 * 1. For-loops: Reference exists outside the loop body
 * 2. Comprehensions: Callable is used as the element or in a tuple element
 */
predicate escapesLoopCapture(CallableExpr callable, AstNode loopNode, Variable loopVar) {
  capturesLoopVariable(callable, loopNode, loopVar) and
  (
    loopNode instanceof For and
    exists(Expr ref | ref.pointsTo(_, _, callable) | not loopNode.contains(ref))
    or
    loopNode.(Comp).getElt() = callable
    or
    loopNode.(Comp).getElt().(Tuple).getAnElt() = callable
  )
}

// Find callable expressions that capture and escape loop variables
from CallableExpr capturedExpr, AstNode loopNode, Variable loopVar
where escapesLoopCapture(capturedExpr, loopNode, loopVar)
select capturedExpr, "Capture of loop variable $@.", loopNode, loopVar.getId()
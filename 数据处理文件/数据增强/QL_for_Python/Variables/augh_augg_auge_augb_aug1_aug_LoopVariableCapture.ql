/**
 * @name Loop variable capture
 * @description Identifies closures capturing loop variables instead of their values
 * @kind problem
 * @tags correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/loop-variable-capture
 */

import python

/**
 * Determines the scope containing iteration variables for loop constructs.
 * - For For-loops: returns the loop's immediate scope
 * - For comprehensions: returns the enclosing function's scope
 */
Scope getIterationScope(AstNode loopNode) {
  result = loopNode.(For).getScope()
  or
  result = loopNode.(Comp).getFunction()
}

/**
 * Detects when a callable captures a loop variable within its iteration scope.
 * Conditions:
 * 1. Variable is defined in the loop's iteration scope
 * 2. Variable is accessed within the callable's inner scope
 * 3. Callable is nested inside the loop construct
 * 4. Variable is either a For-loop target or comprehension iteration variable
 */
predicate capturesLoopVariable(CallableExpr closure, AstNode loopNode, Variable loopVar) {
  loopVar.getScope() = getIterationScope(loopNode) and
  loopVar.getAnAccess().getScope() = closure.getInnerScope() and
  closure.getParentNode+() = loopNode and
  (
    loopNode.(For).getTarget() = loopVar.getAnAccess()
    or
    loopVar = loopNode.(Comp).getAnIterationVariable()
  )
}

/**
 * Determines if a captured loop variable escapes its original loop context.
 * Escape scenarios:
 * 1. For-loops: Reference exists outside the loop body
 * 2. Comprehensions: Callable is used as the element or in a tuple element
 */
predicate escapesLoopCapture(CallableExpr closure, AstNode loopNode, Variable loopVar) {
  capturesLoopVariable(closure, loopNode, loopVar) and
  (
    // For-loop escape condition
    loopNode instanceof For and
    exists(Expr escapedRef | 
      escapedRef.pointsTo(_, _, closure) | 
      not loopNode.contains(escapedRef)
    )
    or
    // Comprehension escape conditions
    loopNode.(Comp).getElt() = closure
    or
    exists(Tuple tuple | 
      tuple = loopNode.(Comp).getElt() and
      tuple.getAnElt() = closure
    )
  )
}

// Identify callable expressions that capture and escape loop variables
from CallableExpr closure, AstNode loopNode, Variable loopVar
where escapesLoopCapture(closure, loopNode, loopVar)
select closure, "Capture of loop variable $@.", loopNode, loopVar.getId()
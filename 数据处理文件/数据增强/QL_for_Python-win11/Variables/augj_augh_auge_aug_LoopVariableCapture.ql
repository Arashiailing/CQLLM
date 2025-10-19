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
 * Determines the scope where iteration variables are defined for loop constructs.
 * For For-loops, returns the loop's own scope.
 * For comprehensions, returns the containing function's scope.
 */
Scope getIterationScope(AstNode loopConstruct) {
  result = loopConstruct.(For).getScope()
  or
  result = loopConstruct.(Comp).getFunction()
}

/**
 * Identifies when a callable expression captures a loop variable within its iteration scope.
 * Conditions:
 * 1. Variable is defined in the loop's iteration scope
 * 2. Variable is accessed within the callable's inner scope
 * 3. Callable is nested inside the loop construct
 * 4. Variable is either a For-loop target or comprehension iteration variable
 */
predicate capturesLoopVariable(CallableExpr closureExpr, AstNode loopConstruct, Variable iterationVar) {
  exists(Scope iterScope, Scope innerScope |
    iterScope = getIterationScope(loopConstruct) and
    iterationVar.getScope() = iterScope and
    innerScope = closureExpr.getInnerScope() and
    iterationVar.getAnAccess().getScope() = innerScope
  ) and
  closureExpr.getParentNode+() = loopConstruct and
  (
    loopConstruct.(For).getTarget() = iterationVar.getAnAccess()
    or
    iterationVar = loopConstruct.(Comp).getAnIterationVariable()
  )
}

/**
 * Determines if a captured loop variable escapes its original loop construct.
 * Escape conditions:
 * 1. For-loops: Reference exists outside the loop body
 * 2. Comprehensions: Callable is used as the element or in a tuple element
 */
predicate escapesLoopCapture(CallableExpr closureExpr, AstNode loopConstruct, Variable iterationVar) {
  capturesLoopVariable(closureExpr, loopConstruct, iterationVar) and
  (
    loopConstruct instanceof For and
    exists(Expr reference | 
      reference.pointsTo(_, _, closureExpr) and 
      not loopConstruct.contains(reference)
    )
    or
    loopConstruct.(Comp).getElt() = closureExpr
    or
    loopConstruct.(Comp).getElt().(Tuple).getAnElt() = closureExpr
  )
}

// Identify callable expressions that capture and escape loop variables
from CallableExpr closureExpr, AstNode loopConstruct, Variable iterationVar
where escapesLoopCapture(closureExpr, loopConstruct, iterationVar)
select closureExpr, "Capture of loop variable $@.", loopConstruct, iterationVar.getId()
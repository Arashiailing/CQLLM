/**
 * @name Loop Variable Capture in Closures
 * @description Detects when closures capture loop variables instead of their values, potentially causing runtime issues.
 * @kind problem
 * @tags correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/loop-variable-capture
 */

import python

/**
 * Retrieves the scope containing iteration variables for a loop construct.
 * For For-loops, returns the loop's own scope.
 * For comprehensions, returns the enclosing function's scope.
 */
Scope getIterationScope(AstNode loopStmt) {
  result = loopStmt.(For).getScope()
  or
  result = loopStmt.(Comp).getFunction()
}

/**
 * Determines if a callable captures a loop variable under these conditions:
 * 1. Variable is defined in the loop's iteration scope
 * 2. Variable is accessed within the callable's inner scope
 * 3. Callable is nested inside the loop construct
 * 4. Variable is either a For-loop target or comprehension iteration variable
 */
predicate capturesLoopVariable(CallableExpr closureExpr, AstNode loopStmt, Variable iterationVar) {
  iterationVar.getScope() = getIterationScope(loopStmt) and
  iterationVar.getAnAccess().getScope() = closureExpr.getInnerScope() and
  closureExpr.getParentNode+() = loopStmt and
  (
    loopStmt.(For).getTarget() = iterationVar.getAnAccess()
    or
    iterationVar = loopStmt.(Comp).getAnIterationVariable()
  )
}

/**
 * Checks if a captured loop variable escapes its original loop context:
 * - For For-loops: Callable is referenced outside the loop body
 * - For comprehensions: Callable is used as the element or tuple element
 */
predicate escapesLoopCapture(CallableExpr closureExpr, AstNode loopStmt, Variable iterationVar) {
  capturesLoopVariable(closureExpr, loopStmt, iterationVar) and
  (
    loopStmt instanceof For and
    exists(Expr ref | ref.pointsTo(_, _, closureExpr) | not loopStmt.contains(ref))
    or
    loopStmt.(Comp).getElt() = closureExpr
    or
    loopStmt.(Comp).getElt().(Tuple).getAnElt() = closureExpr
  )
}

// Find callable expressions that capture and escape loop variables
from CallableExpr closureExpr, AstNode loopStmt, Variable iterationVar
where escapesLoopCapture(closureExpr, loopStmt, iterationVar)
select closureExpr, "Capture of loop variable $@.", loopStmt, iterationVar.getId()
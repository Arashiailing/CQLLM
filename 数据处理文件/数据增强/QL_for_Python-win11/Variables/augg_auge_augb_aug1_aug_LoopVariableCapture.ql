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
Scope getIterationScope(AstNode loopConstruct) {
  result = loopConstruct.(For).getScope()
  or
  result = loopConstruct.(Comp).getFunction()
}

/**
 * Detects when a callable captures a loop variable within its iteration scope.
 * Conditions:
 * 1. Variable is defined in the loop's iteration scope
 * 2. Variable is accessed within the callable's inner scope
 * 3. Callable is nested inside the loop construct
 * 4. Variable is either a For-loop target or comprehension iteration variable
 */
predicate capturesLoopVariable(CallableExpr callableExpr, AstNode loopConstruct, Variable iterationVar) {
  iterationVar.getScope() = getIterationScope(loopConstruct) and
  iterationVar.getAnAccess().getScope() = callableExpr.getInnerScope() and
  callableExpr.getParentNode+() = loopConstruct and
  (
    loopConstruct.(For).getTarget() = iterationVar.getAnAccess()
    or
    iterationVar = loopConstruct.(Comp).getAnIterationVariable()
  )
}

/**
 * Determines if a captured loop variable escapes its original loop context.
 * Escape scenarios:
 * 1. For-loops: Reference exists outside the loop body
 * 2. Comprehensions: Callable is used as the element or in a tuple element
 */
predicate escapesLoopCapture(CallableExpr callableExpr, AstNode loopConstruct, Variable iterationVar) {
  capturesLoopVariable(callableExpr, loopConstruct, iterationVar) and
  (
    loopConstruct instanceof For and
    exists(Expr escapedRef | 
      escapedRef.pointsTo(_, _, callableExpr) | 
      not loopConstruct.contains(escapedRef)
    )
    or
    loopConstruct.(Comp).getElt() = callableExpr
    or
    exists(Tuple tuple | 
      tuple = loopConstruct.(Comp).getElt() and
      tuple.getAnElt() = callableExpr
    )
  )
}

// Identify callable expressions that capture and escape loop variables
from CallableExpr callableExpr, AstNode loopConstruct, Variable iterationVar
where escapesLoopCapture(callableExpr, loopConstruct, iterationVar)
select callableExpr, "Capture of loop variable $@.", loopConstruct, iterationVar.getId()
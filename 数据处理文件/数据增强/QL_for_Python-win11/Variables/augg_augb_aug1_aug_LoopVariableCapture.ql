/**
 * @name Loop variable capture
 * @description Detects when loop variables are captured in closures instead of their values
 * @kind problem
 * @tags correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/loop-variable-capture
 */

import python

/**
 * Retrieves the scope where iteration variables are defined for loop constructs.
 * - For For-loops: returns the loop's immediate scope
 * - For comprehensions: returns the enclosing function's scope
 */
Scope getIterationScope(AstNode loopNode) {
  result = loopNode.(For).getScope()
  or
  result = loopNode.(Comp).getFunction()
}

/**
 * Detects when a callable expression captures a loop variable within its iteration scope.
 * Conditions:
 * 1. Variable is defined in the loop's iteration scope
 * 2. Variable is accessed inside the callable's inner scope
 * 3. Callable is nested within the loop construct
 * 4. Variable is either a For-loop target or comprehension iteration variable
 */
predicate capturesLoopVariable(CallableExpr capturedFunc, AstNode loopNode, Variable loopVar) {
  loopVar.getScope() = getIterationScope(loopNode) and
  loopVar.getAnAccess().getScope() = capturedFunc.getInnerScope() and
  capturedFunc.getParentNode+() = loopNode and
  (
    loopNode.(For).getTarget() = loopVar.getAnAccess()
    or
    loopVar = loopNode.(Comp).getAnIterationVariable()
  )
}

/**
 * Determines if a captured loop variable escapes its original loop context.
 * Escape scenarios:
 * 1. For-loops: Callable is referenced outside the loop body
 * 2. Comprehensions: Callable is used as the element or within a tuple element
 */
predicate escapesLoopCapture(CallableExpr capturedFunc, AstNode loopNode, Variable loopVar) {
  capturesLoopVariable(capturedFunc, loopNode, loopVar) and
  (
    loopNode instanceof For and
    exists(Expr ref | ref.pointsTo(_, _, capturedFunc) | not loopNode.contains(ref))
    or
    exists(Comp comp | comp = loopNode |
      comp.getElt() = capturedFunc or
      comp.getElt().(Tuple).getAnElt() = capturedFunc
    )
  )
}

// Identify callable expressions that capture and escape loop variables
from CallableExpr capturedFunc, AstNode loopNode, Variable loopVar
where escapesLoopCapture(capturedFunc, loopNode, loopVar)
select capturedFunc, "Capture of loop variable $@.", loopNode, loopVar.getId()
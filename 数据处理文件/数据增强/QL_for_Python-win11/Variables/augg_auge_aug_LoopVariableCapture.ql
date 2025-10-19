/**
 * @name Loop Variable Capture in Closures
 * @description Identifies instances where loop variables are captured by closures rather than their values, potentially causing unintended behavior.
 * @kind problem
 * @tags correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/loop-variable-capture
 */

import python

/**
 * Obtains the scope that holds the iteration variables for a given loop node.
 * In the case of For-loops, the scope of the loop itself is returned.
 * For comprehensions, the scope of the enclosing function is returned.
 */
Scope getIterationScope(AstNode loopNode) {
  result = loopNode.(For).getScope()
  or
  result = loopNode.(Comp).getFunction()
}

/**
 * Checks whether a callable expression captures a loop variable in the iteration scope.
 * The conditions are:
 * 1. The variable is defined in the iteration scope of the loop.
 * 2. The variable is accessed within the inner scope of the callable.
 * 3. The callable is nested within the loop node.
 * 4. The variable is either a target in a For-loop or an iteration variable in a comprehension.
 */
predicate capturesLoopVariable(CallableExpr capturedClosure, AstNode loopNode, Variable loopVar) {
  loopVar.getScope() = getIterationScope(loopNode) and
  loopVar.getAnAccess().getScope() = capturedClosure.getInnerScope() and
  capturedClosure.getParentNode+() = loopNode and
  (
    loopNode.(For).getTarget() = loopVar.getAnAccess()
    or
    loopVar = loopNode.(Comp).getAnIterationVariable()
  )
}

/**
 * Determines whether the captured loop variable escapes the original loop node.
 * Escape conditions:
 * 1. For For-loops: A reference to the callable exists outside the loop body.
 * 2. For comprehensions: The callable is used as the element or as an element in a tuple.
 */
predicate escapesLoopCapture(CallableExpr capturedClosure, AstNode loopNode, Variable loopVar) {
  capturesLoopVariable(capturedClosure, loopNode, loopVar) and
  (
    loopNode instanceof For and
    exists(Expr reference | reference.pointsTo(_, _, capturedClosure) | not loopNode.contains(reference))
    or
    loopNode.(Comp).getElt() = capturedClosure
    or
    loopNode.(Comp).getElt().(Tuple).getAnElt() = capturedClosure
  )
}

// Identify callable expressions that capture and escape loop variables
from CallableExpr capturedClosure, AstNode loopNode, Variable loopVar
where escapesLoopCapture(capturedClosure, loopNode, loopVar)
select capturedClosure, "Capture of loop variable $@.", loopNode, loopVar.getId()
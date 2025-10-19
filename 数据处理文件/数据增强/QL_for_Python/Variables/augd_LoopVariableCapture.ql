/**
 * @name Loop variable capture
 * @description Identifies when a loop variable is captured in a closure, which can lead to unexpected behavior
 * as the variable will have its last value from the loop rather than the value at the time of capture.
 * @kind problem
 * @tags correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/loop-variable-capture
 */

import python

// Determines the scope of iteration variables within a loop construct
Scope getLoopIterationScope(AstNode loopNode) {
  result = loopNode.(For).getScope() // For loops have their own scope
  or
  result = loopNode.(Comp).getFunction() // Comprehensions inherit from the containing function
}

// Checks if a callable expression captures a variable from a loop construct
predicate capturesLoopVariable(CallableExpr capturingExpr, AstNode loopNode, Variable loopVar) {
  loopVar.getScope() = getLoopIterationScope(loopNode) and // Variable is in the loop's scope
  loopVar.getAnAccess().getScope() = capturingExpr.getInnerScope() and // Variable is accessed within the callable
  capturingExpr.getParentNode+() = loopNode and // Callable is defined within the loop
  (
    loopNode.(For).getTarget() = loopVar.getAnAccess() // For loop target variable
    or
    loopVar = loopNode.(Comp).getAnIterationVariable() // Comprehension iteration variable
  )
}

// Checks if a captured loop variable escapes the loop construct
predicate escapesLoopVariableCapture(CallableExpr capturingExpr, AstNode loopNode, Variable loopVar) {
  capturesLoopVariable(capturingExpr, loopNode, loopVar) and // Must capture a loop variable
  // Variable escapes if used outside the for loop or in a lambda within a comprehension
  (
    loopNode instanceof For and // For loop case
    exists(Expr e | e.pointsTo(_, _, capturingExpr) | not loopNode.contains(e)) // Referenced outside the loop
    or
    loopNode.(Comp).getElt() = capturingExpr // Direct element in comprehension
    or
    loopNode.(Comp).getElt().(Tuple).getAnElt() = capturingExpr // Element within a tuple in comprehension
  )
}

// Query to find loop variables that are captured and escape
from CallableExpr capturingExpr, AstNode loopNode, Variable loopVar
where escapesLoopVariableCapture(capturingExpr, loopNode, loopVar)
select capturingExpr, "Capture of loop variable $@.", loopNode, loopVar.getId()
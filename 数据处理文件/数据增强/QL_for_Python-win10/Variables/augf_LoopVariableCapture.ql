/**
 * @name Loop variable capture
 * @description Capturing a loop variable instead of its value can lead to unexpected behavior.
 * @kind problem
 * @tags correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/loop-variable-capture
 */

import python

// Determine the scope containing iteration variables for different loop constructs
Scope getIterationScope(AstNode loopNode) {
  result = loopNode.(For).getScope()  // Handle for-loops
  or
  result = loopNode.(Comp).getFunction()  // Handle comprehensions
}

// Check if a callable expression captures a loop variable within its iteration scope
predicate capturesLoopVariable(CallableExpr capturingExpr, AstNode loopNode, Variable loopVar) {
  loopVar.getScope() = getIterationScope(loopNode) and  // Variable must be in iteration scope
  loopVar.getAnAccess().getScope() = capturingExpr.getInnerScope() and  // Access occurs in callable's scope
  capturingExpr.getParentNode+() = loopNode and  // Callable is nested within loop
  (
    loopNode.(For).getTarget() = loopVar.getAnAccess()  // For-loop variable capture
    or
    loopVar = loopNode.(Comp).getAnIterationVariable()  // Comprehension variable capture
  )
}

// Identify cases where captured loop variables escape their original context
predicate escapedLoopVariableCapture(CallableExpr capturingExpr, AstNode loopNode, Variable loopVar) {
  capturesLoopVariable(capturingExpr, loopNode, loopVar) and  // Must capture loop variable
  (
    // Case 1: For-loop variable referenced outside loop body
    loopNode instanceof For and
    exists(Expr ref | ref.pointsTo(_, _, capturingExpr) | not loopNode.contains(ref))
    or
    // Case 2: Comprehension element is the capturing expression
    loopNode.(Comp).getElt() = capturingExpr
    or
    // Case 3: Capturing expression is within a tuple in comprehension
    loopNode.(Comp).getElt().(Tuple).getAnElt() = capturingExpr
  )
}

// Find all callable expressions that capture and escape loop variables
from CallableExpr capturingExpr, AstNode loopNode, Variable loopVar
where escapedLoopVariableCapture(capturingExpr, loopNode, loopVar)
select capturingExpr, "Capture of loop variable $@.", loopNode, loopVar.getId()
/**
 * @name Loop variable capture
 * @description Identifies when loop iteration variables are captured within closures or comprehensions,
 *              causing potential runtime issues due to variable value changes after closure creation.
 * @kind problem
 * @tags correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/loop-variable-capture
 */

import python

// Determines the effective scope for iteration variables in different loop constructs
Scope getIterationVariableScope(AstNode loopConstruct) {
  result = loopConstruct.(For).getScope() // Scope for standard for-loops
  or
  result = loopConstruct.(Comp).getFunction() // Scope for comprehensions
}

// Verifies if a callable expression captures a loop iteration variable
predicate capturesIterationVar(CallableExpr callableExpr, AstNode loopConstruct, Variable iterationVar) {
  iterationVar.getScope() = getIterationVariableScope(loopConstruct) and // Variable belongs to loop scope
  iterationVar.getAnAccess().getScope() = callableExpr.getInnerScope() and // Access occurs within callable
  callableExpr.getParentNode+() = loopConstruct and // Callable is nested inside loop
  (
    loopConstruct.(For).getTarget() = iterationVar.getAnAccess() // For-loop target variable
    or
    iterationVar = loopConstruct.(Comp).getAnIterationVariable() // Comprehension iteration variable
  )
}

// Checks if captured iteration variable escapes its original scope
predicate iterationVarEscapes(CallableExpr callableExpr, AstNode loopConstruct, Variable iterationVar) {
  capturesIterationVar(callableExpr, loopConstruct, iterationVar) and // Confirm variable capture
  (
    // Escape scenarios in for-loops
    loopConstruct instanceof For and
    exists(Expr escapingRef | 
      escapingRef.pointsTo(_, _, callableExpr) and // Reference points to captured expression
      not loopConstruct.contains(escapingRef) // Reference exists outside loop
    )
    or
    // Escape scenarios in comprehensions
    loopConstruct.(Comp).getElt() = callableExpr // Direct element capture
    or
    loopConstruct.(Comp).getElt().(Tuple).getAnElt() = callableExpr // Tuple element capture
  )
}

// Find all callable expressions capturing escaping iteration variables
from CallableExpr callableExpr, AstNode loopConstruct, Variable iterationVar
where iterationVarEscapes(callableExpr, loopConstruct, iterationVar)
select callableExpr, "Capture of loop variable $@.", loopConstruct, iterationVar.getId()
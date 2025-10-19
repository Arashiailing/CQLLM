/**
 * @name An assert statement has a side-effect
 * @description Identifies assert statements that include expressions with side-effects,
 *              leading to different behavior between normal execution and optimized builds
 *              where assertions are disabled.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/side-effect-in-assert
 */

import python

// Predicate that checks if an expression references a function known to have side effects
predicate expressionHasSideEffectFunction(Expr expr) {
  // Determine if the expression is an attribute access or name reference to a side-effect function
  exists(string functionName | 
    functionName = expr.(Attribute).getName() or functionName = expr.(Name).getId() |
    functionName in [
        "print", "write", "append", "pop", "remove", "discard", "delete", "close", "open", "exit"
      ]
  )
}

// Predicate that identifies calls to subprocess module functions which execute external commands
predicate isSubprocessModuleCall(Call callExpr) {
  // Match calls to subprocess functions that spawn external processes
  callExpr.getAFlowNode() = Value::named("subprocess.call").getACall()
  or
  callExpr.getAFlowNode() = Value::named("subprocess.check_call").getACall()
  or
  callExpr.getAFlowNode() = Value::named("subprocess.check_output").getACall()
}

// Predicate that determines if an expression could potentially produce side effects
predicate expressionMayHaveSideEffect(Expr expr) {
  // Check for yield expressions (excluding those within comprehensions)
  (expr instanceof Yield and not exists(Comp c | c.contains(expr)))
  or
  // Check for yield from expressions
  expr instanceof YieldFrom
  or
  // Check for function calls that may have side effects
  (expr instanceof Call and (
    expressionHasSideEffectFunction(expr.(Call).getFunc()) or 
    isSubprocessModuleCall(expr)
  ))
}

// Main query that locates assert statements containing expressions with side effects
from Assert assertionStatement, Expr problematicExpression
where 
  expressionMayHaveSideEffect(problematicExpression) and 
  assertionStatement.contains(problematicExpression)
select assertionStatement, "This 'assert' statement contains an $@ which may have side effects.", problematicExpression, "expression"
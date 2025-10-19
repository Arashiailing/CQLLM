/**
 * @name An assert statement has a side-effect
 * @description Identifies assert statements containing expressions with side-effects,
 *              which cause behavioral differences between normal and optimized execution.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/side-effect-in-assert
 */

import python

// Identifies expressions referencing functions with known side effects
predicate expressionContainsSideEffectFunction(Expr expression) {
  exists(string functionName | 
    (functionName = expression.(Attribute).getName() or 
     functionName = expression.(Name).getId()) and
    functionName in [
        "print", "write", "append", "pop", "remove", "discard", "delete", "close", "open", "exit"
      ]
  )
}

// Detects subprocess module calls that execute external commands
predicate isSubprocessCall(Call callExpression) {
  callExpression.getAFlowNode() = Value::named("subprocess.call").getACall() or
  callExpression.getAFlowNode() = Value::named("subprocess.check_call").getACall() or
  callExpression.getAFlowNode() = Value::named("subprocess.check_output").getACall()
}

// Determines if an expression may produce side effects through various mechanisms
predicate hasSideEffectPotential(Expr expression) {
  // Generator expressions that suspend execution
  (expression instanceof Yield and not exists(Comp c | c.contains(expression))) or
  expression instanceof YieldFrom or
  // Function calls with side-effect operations
  (expression instanceof Call and expressionContainsSideEffectFunction(expression.(Call).getFunc())) or
  // External process invocations
  (expression instanceof Call and isSubprocessCall(expression))
}

// Primary detection logic for assert statements containing side-effect expressions
from Assert assertionStatement, Expr sideEffectExpression
where 
  hasSideEffectPotential(sideEffectExpression) and 
  assertionStatement.contains(sideEffectExpression)
select 
  assertionStatement, 
  "This 'assert' statement contains an $@ which may have side effects.", 
  sideEffectExpression, 
  "expression"
/**
 * @name An assert statement has a side-effect
 * @description Identifies assert statements that include expressions with side effects,
 *              leading to different behavior in normal versus optimized execution modes.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/side-effect-in-assert
 */

import python

// Predicate that checks if an expression contains a function call with known side effects
predicate expressionHasSideEffectFunction(Expr expression) {
  // Verify if the expression is an attribute or name reference to a function with side effects
  exists(string functionName | 
    functionName = expression.(Attribute).getName() or functionName = expression.(Name).getId() |
    functionName in [
        "print", "write", "append", "pop", "remove", "discard", "delete", "close", "open", "exit"
      ]
  )
}

// Predicate that identifies subprocess module calls which inherently have side effects
predicate isSubprocessInvocation(Call functionCall) {
  // Detect calls to subprocess module functions that execute external commands
  functionCall.getAFlowNode() = Value::named("subprocess.call").getACall()
  or
  functionCall.getAFlowNode() = Value::named("subprocess.check_call").getACall()
  or
  functionCall.getAFlowNode() = Value::named("subprocess.check_output").getACall()
}

// Predicate that determines if an expression could potentially produce side effects
predicate expressionMayHaveSideEffect(Expr expression) {
  // Check for Yield expressions (excluding those within comprehensions)
  expression instanceof Yield and not exists(Comp c | c.contains(expression))
  or
  // Check for YieldFrom expressions
  expression instanceof YieldFrom
  or
  // Check for function calls that have side effects
  expression instanceof Call and expressionHasSideEffectFunction(expression.(Call).getFunc())
  or
  // Check for subprocess calls
  expression instanceof Call and isSubprocessInvocation(expression)
}

// Main query that identifies assert statements containing expressions with side effects
from Assert assertionStatement, Expr sideEffectExpression
where expressionMayHaveSideEffect(sideEffectExpression) and assertionStatement.contains(sideEffectExpression)
select assertionStatement, "This 'assert' statement contains an $@ which may have side effects.", sideEffectExpression, "expression"
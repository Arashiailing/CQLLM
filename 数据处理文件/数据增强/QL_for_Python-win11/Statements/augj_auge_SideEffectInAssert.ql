/**
 * @name Detects side-effect expressions in assert statements
 * @description Expressions with side effects in assert statements cause behavioral
 *              differences between normal and optimized execution modes.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/side-effect-in-assert
 */

import python

// Identifies expressions containing function calls with known side effects
predicate hasSideEffectFunc(Expr expression) {
  exists(string functionName | 
    (functionName = expression.(Attribute).getName() or 
     functionName = expression.(Name).getId()) and
    functionName in [
        "print", "write", "append", "pop", "remove", 
        "discard", "delete", "close", "open", "exit"
      ]
  )
}

// Detects calls to subprocess functions that have side effects
predicate isSubprocessCall(Call subprocessCall) {
  subprocessCall.getAFlowNode() = Value::named("subprocess.call").getACall() or
  subprocessCall.getAFlowNode() = Value::named("subprocess.check_call").getACall() or
  subprocessCall.getAFlowNode() = Value::named("subprocess.check_output").getACall()
}

// Determines if an expression might produce side effects
predicate mayHaveSideEffect(Expr expression) {
  // Explicit yield expressions
  (expression instanceof Yield and not exists(Comp comprehension | comprehension.contains(expression))) or
  // Yield from expressions
  expression instanceof YieldFrom or
  // Side-effect function calls
  (expression instanceof Call and hasSideEffectFunc(expression.(Call).getFunc())) or
  // Subprocess calls
  (expression instanceof Call and isSubprocessCall(expression))
}

// Identifies assert statements containing potentially side-effect expressions
from Assert assertion, Expr expression
where mayHaveSideEffect(expression) and assertion.contains(expression)
select assertion, "This 'assert' statement contains a $@ which may have side effects.", expression, "expression"
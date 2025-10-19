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
predicate expressionHasSideEffectFunction(Expr exprToCheck) {
  // Verify if the expression is an attribute or name reference to a function with side effects
  exists(string funcName | 
    funcName = exprToCheck.(Attribute).getName() or funcName = exprToCheck.(Name).getId() |
    funcName in [
        "print", "write", "append", "pop", "remove", "discard", "delete", "close", "open", "exit"
      ]
  )
}

// Predicate that identifies subprocess module calls which inherently have side effects
predicate isSubprocessInvocation(Call subprocessCall) {
  // Detect calls to subprocess module functions that execute external commands
  subprocessCall.getAFlowNode() = Value::named("subprocess.call").getACall()
  or
  subprocessCall.getAFlowNode() = Value::named("subprocess.check_call").getACall()
  or
  subprocessCall.getAFlowNode() = Value::named("subprocess.check_output").getACall()
}

// Predicate that determines if an expression could potentially produce side effects
predicate expressionMayHaveSideEffect(Expr exprToCheck) {
  // Check for generator expressions that have side effects
  (exprToCheck instanceof Yield and not exists(Comp c | c.contains(exprToCheck)))
  or
  exprToCheck instanceof YieldFrom
  or
  // Check for function calls that have side effects
  (exprToCheck instanceof Call and 
    (expressionHasSideEffectFunction(exprToCheck.(Call).getFunc()) or
     isSubprocessInvocation(exprToCheck)))
}

// Main query that identifies assert statements containing expressions with side effects
from Assert assertStmt, Expr exprWithSideEffect
where expressionMayHaveSideEffect(exprWithSideEffect) and assertStmt.contains(exprWithSideEffect)
select assertStmt, "This 'assert' statement contains an $@ which may have side effects.", exprWithSideEffect, "expression"
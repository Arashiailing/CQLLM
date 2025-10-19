/**
 * @name An assert statement has a side-effect
 * @description Detects assert statements containing expressions with side-effects,
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

// Predicate to identify expressions containing function calls with known side effects
predicate exprContainsSideEffectFunc(Expr expr) {
  // Check if the expression is an attribute or name reference to a side-effect function
  exists(string funcName | 
    funcName = expr.(Attribute).getName() or funcName = expr.(Name).getId() |
    funcName in [
        "print", "write", "append", "pop", "remove", "discard", "delete", "close", "open", "exit"
      ]
  )
}

// Predicate to identify subprocess module calls which inherently have side effects
predicate isSubprocessCall(Call callExpr) {
  // Match calls to subprocess module functions that execute external commands
  callExpr.getAFlowNode() = Value::named("subprocess.call").getACall()
  or
  callExpr.getAFlowNode() = Value::named("subprocess.check_call").getACall()
  or
  callExpr.getAFlowNode() = Value::named("subprocess.check_output").getACall()
}

// Predicate to determine if an expression may produce side effects
predicate hasPotentialSideEffect(Expr expr) {
  // Case 1: Yield expressions (excluding those in comprehensions)
  expr instanceof Yield and not exists(Comp c | c.contains(expr))
  or
  // Case 2: YieldFrom expressions
  expr instanceof YieldFrom
  or
  // Case 3: Function calls with side effects
  expr instanceof Call and exprContainsSideEffectFunc(expr.(Call).getFunc())
  or
  // Case 4: Subprocess calls
  expr instanceof Call and isSubprocessCall(expr)
}

// Main query to find assert statements containing expressions with side effects
from Assert assertStmt, Expr exprWithSideEffect
where hasPotentialSideEffect(exprWithSideEffect) and assertStmt.contains(exprWithSideEffect)
select assertStmt, "This 'assert' statement contains an $@ which may have side effects.", exprWithSideEffect, "expression"
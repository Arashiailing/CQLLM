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
predicate hasSideEffectFunc(Expr expr) {
  exists(string funcName | 
    funcName = expr.(Attribute).getName() or 
    funcName = expr.(Name).getId() |
    funcName in [
        "print", "write", "append", "pop", "remove", 
        "discard", "delete", "close", "open", "exit"
      ]
  )
}

// Detects calls to subprocess functions that have side effects
predicate isSubprocessCall(Call callExpr) {
  callExpr.getAFlowNode() = Value::named("subprocess.call").getACall()
  or
  callExpr.getAFlowNode() = Value::named("subprocess.check_call").getACall()
  or
  callExpr.getAFlowNode() = Value::named("subprocess.check_output").getACall()
}

// Determines if an expression might produce side effects
predicate mayHaveSideEffect(Expr expr) {
  (expr instanceof Yield and not exists(Comp c | c.contains(expr)))  // Explicit yield
  or
  expr instanceof YieldFrom  // Yield from expressions
  or
  (expr instanceof Call and hasSideEffectFunc(expr.(Call).getFunc()))  // Side-effect function calls
  or
  (expr instanceof Call and isSubprocessCall(expr))  // Subprocess calls
}

// Identifies assert statements containing potentially side-effect expressions
from Assert assertStmt, Expr expr
where mayHaveSideEffect(expr) and assertStmt.contains(expr)
select assertStmt, "This 'assert' statement contains a $@ which may have side effects.", expr, "expression"
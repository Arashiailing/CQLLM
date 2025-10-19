/**
 * @name An assert statement has a side-effect
 * @description Identifies assert statements containing expressions with side-effects,
 *              leading to behavioral differences between normal and optimized execution.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/side-effect-in-assert
 */

import python

// Predicate to detect expressions referencing functions with known side effects
predicate exprHasSideEffectFunc(Expr expr) {
  // Verify if expression refers to a function with side effects
  exists(string sideEffectFunc | 
    sideEffectFunc = expr.(Attribute).getName() or sideEffectFunc = expr.(Name).getId() |
    sideEffectFunc in [
        "print", "write", "append", "pop", "remove", "discard", "delete", "close", "open", "exit"
      ]
  )
}

// Predicate to identify subprocess module calls (inherently side-effecting)
predicate isSubprocessModuleCall(Call callExpr) {
  // Match subprocess functions executing external commands
  callExpr.getAFlowNode() = Value::named("subprocess.call").getACall()
  or
  callExpr.getAFlowNode() = Value::named("subprocess.check_call").getACall()
  or
  callExpr.getAFlowNode() = Value::named("subprocess.check_output").getACall()
}

// Predicate to determine if an expression may produce side effects
predicate mayHaveSideEffect(Expr expr) {
  // Case 1: Yield expressions (excluding comprehensions)
  expr instanceof Yield and not exists(Comp c | c.contains(expr))
  or
  // Case 2: YieldFrom expressions
  expr instanceof YieldFrom
  or
  // Case 3: Function calls with known side effects
  exists(Call funcCall | 
    expr = funcCall and exprHasSideEffectFunc(funcCall.getFunc())
  )
  or
  // Case 4: Subprocess calls
  exists(Call subprocessCall | 
    expr = subprocessCall and isSubprocessModuleCall(subprocessCall)
  )
}

// Main query detecting assert statements containing side-effecting expressions
from Assert assertStatement, Expr sideEffectExpr
where 
  mayHaveSideEffect(sideEffectExpr) and 
  assertStatement.contains(sideEffectExpr)
select assertStatement, "This 'assert' statement contains a $@ which may have side effects.", sideEffectExpr, "expression"
/**
 * @name An assert statement has a side-effect
 * @description Side-effects in assert statements result in differences between normal
 *              and optimized behavior.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/side-effect-in-assert
 */

import python

// Identifies expressions containing built-in functions with known side effects
predicate isBuiltinFunctionWithSideEffects(Expr expr) {
  exists(string funcName | 
    funcName = expr.(Attribute).getName() or funcName = expr.(Name).getId() |
    funcName in [
        "print", "write", "append", "pop", "remove", "discard", "delete", "close", "open", "exit"
      ]
  )
}

// Detects subprocess module calls that execute system commands
predicate isSubprocessCallWithSideEffect(Call callExpr) {
  exists(string subprocessFuncName | 
    subprocessFuncName = "subprocess.call" or 
    subprocessFuncName = "subprocess.check_call" or 
    subprocessFuncName = "subprocess.check_output" |
    callExpr.getAFlowNode() = Value::named(subprocessFuncName).getACall()
  )
}

// Determines if an expression likely produces side effects
predicate hasProbableSideEffect(Expr expr) {
  // Yield expressions (excluding pseudo-yields in comprehensions)
  (expr instanceof Yield and not exists(Comp c | c.contains(expr)))
  or
  // YieldFrom expressions
  expr instanceof YieldFrom
  or
  // Calls to built-in functions or subprocess commands with side effects
  exists(Call callExpr | 
    callExpr = expr and 
    (isBuiltinFunctionWithSideEffects(callExpr.getFunc()) or 
     isSubprocessCallWithSideEffect(callExpr))
  )
}

// Locates assert statements containing side-effect expressions
from Assert assertStmt, Expr expr
where hasProbableSideEffect(expr) and assertStmt.contains(expr)
select assertStmt, "This 'assert' statement contains an $@ which may have side effects.", expr, "expression"
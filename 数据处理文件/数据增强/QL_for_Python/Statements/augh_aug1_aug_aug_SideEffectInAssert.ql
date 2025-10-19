/**
 * @name An assert statement has a side-effect
 * @description Detects assert statements containing expressions with side effects,
 *              which can cause behavioral differences between normal and optimized execution.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/side-effect-in-assert
 */

import python

// Identifies expressions that involve built-in functions known to have side effects
predicate sideEffectFunctionCall(Expr expr) {
  exists(string funcName | 
    funcName = expr.(Attribute).getName() or funcName = expr.(Name).getId() |
    funcName in [
        "print", "write", "append", "pop", "remove", "discard", "delete", "close", "open", "exit"
      ]
  )
}

// Detects calls to specific subprocess module functions that execute system commands
predicate subprocessSystemCall(Call methodCall) {
  exists(string subprocessFuncName | 
    subprocessFuncName = "subprocess.call" or 
    subprocessFuncName = "subprocess.check_call" or 
    subprocessFuncName = "subprocess.check_output" |
    methodCall.getAFlowNode() = Value::named(subprocessFuncName).getACall()
  )
}

// Determines if an expression potentially produces side effects
predicate hasSideEffect(Expr targetExpr) {
  // Case 1: Standalone yield expressions (excluding pseudo-yields in comprehensions)
  (targetExpr instanceof Yield and not exists(Comp c | c.contains(targetExpr)))
  or
  // Case 2: YieldFrom expressions
  targetExpr instanceof YieldFrom
  or
  // Case 3: Calls to built-in functions with known side effects
  exists(Call methodCall | 
    methodCall = targetExpr and 
    sideEffectFunctionCall(methodCall.getFunc())
  )
  or
  // Case 4: Calls to subprocess system commands
  exists(Call methodCall | 
    methodCall = targetExpr and 
    subprocessSystemCall(methodCall)
  )
}

// Finds assert statements containing expressions with potential side effects
from Assert assertStmt, Expr targetExpr
where hasSideEffect(targetExpr) and assertStmt.contains(targetExpr)
select assertStmt, "This 'assert' statement contains an $@ which may have side effects.", targetExpr, "expression"
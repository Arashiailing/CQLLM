/**
 * @name An assert statement has a side-effect
 * @description Identifies assert statements that include expressions with side effects,
 *              leading to different behaviors between normal execution and optimized builds.
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
predicate exprHasSideEffectFunction(Expr expr) {
  // Check if the expression is an attribute or name reference to a side-effect function
  exists(string functionName | 
    (functionName = expr.(Attribute).getName() or functionName = expr.(Name).getId()) and
    functionName in [
        "print", "write", "append", "pop", "remove", "discard", "delete", "close", "open", "exit"
      ]
  )
}

// Predicate to determine if an expression may produce side effects
predicate expressionMayHaveSideEffect(Expr expr) {
  // Case 1: Yield expressions (excluding those in comprehensions)
  (expr instanceof Yield and not exists(Comp c | c.contains(expr))) or
  // Case 2: YieldFrom expressions
  expr instanceof YieldFrom or
  // Case 3: Function calls with side effects
  (expr instanceof Call and 
    (exprHasSideEffectFunction(expr.(Call).getFunc()) or
     // Case 4: Subprocess calls (merged into the function call case)
     expr.getAFlowNode() = Value::named("subprocess.call").getACall() or
     expr.getAFlowNode() = Value::named("subprocess.check_call").getACall() or
     expr.getAFlowNode() = Value::named("subprocess.check_output").getACall())
  )
}

// Main query to find assert statements containing expressions with side effects
from Assert assertion, Expr sideEffectExpr
where expressionMayHaveSideEffect(sideEffectExpr) and assertion.contains(sideEffectExpr)
select assertion, "This 'assert' statement contains a $@ which may produce side effects.", sideEffectExpr, "expression"
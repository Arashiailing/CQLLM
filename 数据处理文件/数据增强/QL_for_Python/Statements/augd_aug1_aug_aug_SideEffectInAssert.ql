/**
 * @name An assert statement has a side-effect
 * @description Side-effects in assert statements result in differences between normal
 *              and optimized behavior, potentially causing unexpected behavior when
 *              Python is run with optimization flags.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/side-effect-in-assert
 */

import python

/**
 * Determines if an expression references a built-in function known to have side effects.
 * This predicate checks for function names that modify state or produce external effects.
 */
predicate builtin_func_with_side_effects(Expr expression) {
  exists(string funcName | 
    funcName = expression.(Attribute).getName() or funcName = expression.(Name).getId() |
    funcName in [
        "print", "write", "append", "pop", "remove", "discard", "delete", "close", "open", "exit"
      ]
  )
}

/**
 * Identifies calls to subprocess module functions that execute system commands.
 * These calls inherently have side effects as they interact with the operating system.
 */
predicate subprocess_call_with_side_effect(Call callExpr) {
  exists(string subprocFuncName | 
    subprocFuncName = "subprocess.call" or 
    subprocFuncName = "subprocess.check_call" or 
    subprocFuncName = "subprocess.check_output" |
    callExpr.getAFlowNode() = Value::named(subprocFuncName).getACall()
  )
}

/**
 * Determines if an expression likely has side effects by checking various patterns.
 * This includes yield expressions, calls to built-in functions with side effects,
 * and subprocess calls that execute system commands.
 */
predicate has_probable_side_effect(Expr expression) {
  // Check for explicit yield expressions (excluding those in comprehensions)
  (expression instanceof Yield and not exists(Comp comprehension | comprehension.contains(expression)))
  or
  // Check for YieldFrom expressions
  expression instanceof YieldFrom
  or
  // Check for calls to built-in functions with side effects
  exists(Call callExpr | 
    callExpr = expression and 
    builtin_func_with_side_effects(callExpr.getFunc())
  )
  or
  // Check for subprocess calls that execute system commands
  exists(Call callExpr | 
    callExpr = expression and 
    subprocess_call_with_side_effect(callExpr)
  )
}

// Main query: Find assert statements containing expressions with side effects
from Assert assertStmt, Expr expr
where has_probable_side_effect(expr) and assertStmt.contains(expr)
select assertStmt, "This 'assert' statement contains an $@ which may have side effects.", expr, "expression"
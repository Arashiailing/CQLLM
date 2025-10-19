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
predicate isBuiltinFunctionWithSideEffects(Expr expression) {
  exists(string funcName | 
    funcName = expression.(Attribute).getName() or funcName = expression.(Name).getId() |
    funcName in [
        "print", "write", "append", "pop", "remove", "discard", "delete", "close", "open", "exit"
      ]
  )
}

// Detects subprocess module calls that execute system commands
predicate isSubprocessCallWithSideEffect(Call call) {
  exists(string subprocessFunc | 
    subprocessFunc = "subprocess.call" or 
    subprocessFunc = "subprocess.check_call" or 
    subprocessFunc = "subprocess.check_output" |
    call.getAFlowNode() = Value::named(subprocessFunc).getACall()
  )
}

// Determines if an expression likely produces side effects
predicate hasProbableSideEffect(Expr expression) {
  // Yield expressions (excluding pseudo-yields in comprehensions)
  (expression instanceof Yield and not exists(Comp c | c.contains(expression)))
  or
  // YieldFrom expressions
  expression instanceof YieldFrom
  or
  // Calls to built-in functions with side effects
  exists(Call call | 
    call = expression and 
    isBuiltinFunctionWithSideEffects(call.getFunc())
  )
  or
  // Subprocess system command invocations
  exists(Call call | 
    call = expression and 
    isSubprocessCallWithSideEffect(call)
  )
}

// Locates assert statements containing side-effect expressions
from Assert assertStatement, Expr expression
where hasProbableSideEffect(expression) and assertStatement.contains(expression)
select assertStatement, "This 'assert' statement contains an $@ which may have side effects.", expression, "expression"
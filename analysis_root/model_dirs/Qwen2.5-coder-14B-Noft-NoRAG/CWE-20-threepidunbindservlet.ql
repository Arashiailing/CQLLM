import python

/**
 * Detects CWE-20: Improper Input Validation in Python code.
 * This query looks for cases where user input is directly used to construct file paths
 * without proper validation.
 */

from File file, Function function, Call call, Expr inputExpr
where
  // Check if the function is called with user input
  call.getCallee() = function and
  // Check if the function constructs a file path
  function.getName() = "open" and
  // Check if the input expression is directly used in the file path
  call.getArgument(0) = inputExpr and
  // Check if the input expression is user-controlled
  inputExpr instanceof UserInput
select call, "Potential path injection vulnerability: User input is directly used to construct a file path."
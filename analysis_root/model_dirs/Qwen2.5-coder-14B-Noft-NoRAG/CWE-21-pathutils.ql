import python

/**
 * This query detects CWE-21: Pathname Traversal and Equivalence Errors.
 * It identifies instances where user input is used to construct file paths without proper validation.
 */

from FunctionCall fc, Expr userInput, Expr filePath
where fc.getCallee().getName() = "open" and
      fc.getArgument(0) = userInput and
      not exists(Expr validation | validation = userInput.getAnArgument() and
                 validation.getType().hasName("Path"))
select userInput, "User input is used to construct a file path without proper validation."
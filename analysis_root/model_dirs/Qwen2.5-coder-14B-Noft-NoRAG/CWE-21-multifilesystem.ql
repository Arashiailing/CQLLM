import python

/**
 * Detects CWE-21: Pathname Traversal and Equivalence Errors
 * This query looks for potential path injection vulnerabilities in Python code.
 */
from File f, Call call, StringLiteral str
where
  // Check if the file is a Python file
  f.hasExtension("py") and
  // Check if the call is to a function that can be used for file operations
  call.getCallee().getName() = "open" and
  // Check if the call has a string literal argument
  call.getArgument(0) = str and
  // Check if the string literal contains a path traversal pattern
  str.getValue().matches("%.*%\\.%.*")
select call, "Potential path injection vulnerability detected in file operation."
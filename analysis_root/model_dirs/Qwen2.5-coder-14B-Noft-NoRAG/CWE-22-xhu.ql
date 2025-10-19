import python

/**
 * CWE-22: Path Injection
 *
 * This query detects instances where user-controlled input is used to construct a file path.
 */
from File file, Expr userInput, Expr pathExpr
where
  // Check if the path expression contains user input
  pathExpr = user_input +
  // Check if the file is accessed using the path expression
  file.getPath() = pathExpr
select pathExpr, "This path expression uses user-controlled input, which can lead to path injection."
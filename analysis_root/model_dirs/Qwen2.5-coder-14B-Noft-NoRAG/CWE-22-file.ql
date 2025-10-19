import python

/**
 * CWE-22: Path Injection
 * Detects the use of uncontrolled data in file path expressions.
 */

from File file, Expr pathExpr, DataFlow::Node sink
where file.getPath().matches(".*\\.py") and
      DataFlow::localFlow(pathExpr, sink) and
      sink instanceof FileSystemAccess::PathNode
select pathExpr, "This expression is influenced by user input and may lead to path injection."
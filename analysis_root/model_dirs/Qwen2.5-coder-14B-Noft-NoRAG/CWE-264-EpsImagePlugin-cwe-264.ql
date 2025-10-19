import python

/**
 * CWE-264: Path Injection
 *
 * This query detects potential path injection vulnerabilities in Python code.
 * It looks for instances where user input is directly used to construct file paths.
 */

from Call call, StringLiteral literal
where call.getCallee().getName() = "open" and
      call.getArgument(0) = literal and
      exists(DataFlow::PathNode src, DataFlow::PathNode sink |
        DataFlow::localFlow(src, sink) and
        src.asExpr() instanceof UserInput and
        sink.asExpr() = literal
      )
select call, "This call to 'open' with a string literal may be vulnerable to path injection."
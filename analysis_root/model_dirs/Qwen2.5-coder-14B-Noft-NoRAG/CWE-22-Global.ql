import python

/**
 * A query to detect CWE-22: Path Injection vulnerability.
 * This query looks for cases where user-controlled data is used in path expressions.
 */

from Call call, StringLiteral path
where call.getCallee().getName() = "open" and
      call.getArgument(0) = path and
      exists(DataFlow::Node userInput | DataFlow::localFlow(userInput, path))
select call, "This call to 'open' uses user-controlled data in the path expression, which can lead to path injection."
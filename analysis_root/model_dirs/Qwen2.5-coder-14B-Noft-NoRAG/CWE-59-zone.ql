import python

/**
 * CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * This query detects instances where a file is accessed using a path that may be
 * influenced by user input, potentially leading to path traversal vulnerabilities.
 */

from Call call, StringLiteral path
where call.getCallee().getName() = "open" and
      call.getArgument(0) = path and
      path.getValue().matches(".*\\%s.*")
select call, "This call to 'open' uses a potentially unsafe path: " + path.getValue()
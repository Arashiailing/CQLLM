import python

/**
 * A query to detect CWE-22: Path Injection vulnerability in Python code.
 * This query looks for cases where user input is directly used in file path operations.
 */

from Call call, DataFlow::Node src, DataFlow::Node sink
where call.getCallee().getName() = "open" and
      DataFlow::localFlow(src, sink) and
      src instanceof Expr and
      src instanceof UserInput
select call, "This call to 'open' uses user input in the file path, which can lead to Path Injection vulnerability."
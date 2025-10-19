/**
 * @name CWE-134: Use of Externally-Controlled Format String
 * @description The product uses a function that accepts a format string as an argument,
 *              but the format string originates from an external source.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision medium
 * @id py/format-string
 * @tags security
 *       external/cwe/cwe-134
 */

import python
import semmle.python.security.dataflow.FormatStringQuery
import FormatStringFlow::PathGraph

from FormatStringFlow::PathNode source, FormatStringFlow::PathNode sink
where FormatStringFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This formatting operation depends on a $@.", source.getNode(),
  "user-provided value"
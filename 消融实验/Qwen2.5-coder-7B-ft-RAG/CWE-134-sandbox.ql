/**
 * @name CWE-134: Use of Externally-Controlled Format String
 * @description The product uses a function that accepts a format string as an argument,
 *              but the format string originates from an external source.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision medium
 * @id py/format-string
 * @tags security
 *       external/cwe/cwe-134
 */

import python
import semmle.python.security.dataflow.FormatStringInjectionQuery
import FormatStringInjectionFlow::PathGraph

from FormatStringInjectionFlow::PathNode source, FormatStringInjectionFlow::PathNode sink
where FormatStringInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This format string depends on a $@.", source.getNode(),  "user-provided value"
/**
 * @name CWE-400: Reflected Cross-Site Scripting (XSS)
 * @description Detects cross-site scripting vulnerabilities where untrusted input is reflected in the output without proper sanitization.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision high
 * @id py/reflected-xss
 * @tags security
 *       external/cwe/cwe-079
 *       external/cwe/cwe-116
 */

import python
import semmle.python.security.dataflow.ReflectedXssQuery
import ReflectedXssFlow::PathGraph

from ReflectedXssFlow::PathNode source, ReflectedXssFlow::PathNode sink
where ReflectedXssFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Cross-site scripting vulnerability due to a $@.", source.getNode(), "user-provided value"
/**
 * @name CWE-93: Improper Neutralization of CRLF Sequences ('CRLF Injection')
 * @description The product uses CRLF (carriage return line feeds) as a special element, e.g. to separate lines or records, but it does not neutralize or incorrectly neutralizes CRLF sequences from inputs.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision high
 * @id py/bottle
 * @tags security
 *       external/cwe/cwe-93
 */

import python
import semmle.python.security.dataflow.HttpHeaderInjectionQuery
import HttpHeaderInjectionFlow::PathGraph

from HttpHeaderInjectionFlow::PathNode source, HttpHeaderInjectionFlow::PathNode sink
where HttpHeaderInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This HTTP header construction depends on a $@.", source.getNode(), "user-provided value"
/**
 * @name CWE-93: Improper Neutralization of CRLF Sequences ('CRLF Injection')
 * @description The product uses CRLF (carriage return line feeds) as a special element, e.g. to separate lines or records, but it does not neutralize or incorrectly neutralizes CRLF sequences from inputs.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 5.0
 * @security-severity 5.0
 * @id py/bottle
 */

import python
import semmle.python.security.dataflow.HttpHeaderInjectionQuery
import HeaderInjectionFlow::PathGraph
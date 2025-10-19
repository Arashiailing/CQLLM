/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision medium
 * @id py/emailutils
 * @tags correctness
 *       external/cwe/cwe-020
 */

import python
import semmle.python.security.dataflow.HttpHeaderInjectionQuery
import HttpHeaderInjectionFlow::PathGraph

from HttpHeaderInjectionFlow::PathNode source, HttpHeaderInjectionFlow::PathNode sink
where HttpHeaderInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This HTTP header is constructed from a $@.", source.getNode(),  "user-provided value"
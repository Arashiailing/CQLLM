/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind view
 * @id py/views-cwe-20
 */

import python
import semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow
import semmle.python.filters.Tests

view public module SqlInjectionQuery/4 {
  predicate untrusted_source(Source s) { s.isUntrustedSource() }
  predicate tainted_sink(Sink t) { t.isTainted() }
  predicate query_flow(QueryNode src, QueryNode dst) { dataflow::flowPath(src, dst) }
}
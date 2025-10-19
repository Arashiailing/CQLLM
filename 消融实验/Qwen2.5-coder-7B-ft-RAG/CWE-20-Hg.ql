/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind problem
 * @problem.severity error
 * @security-severity 5.0
 * @precision high
 * @id py/Hg
 */

import python
import semmle.python.security.dataflow.NumericComparisonQuery
import NumericComparisonFlow::PathGraph

from NumericComparisonFlow::PathNode source, NumericComparisonFlow::PathNode sink
where NumericComparisonFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Numeric comparison uses a $@.", source.getNode(),
  "non-literal value"
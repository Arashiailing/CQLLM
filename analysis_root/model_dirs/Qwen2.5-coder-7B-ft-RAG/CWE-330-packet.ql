/**
 * @name CWE-330: Use of Insufficiently Random Values
 * @description The product uses insufficiently random numbers or values in a security context that depends on unpredictable numbers.
 * @kind problem
 * @problem.severity warning
 * @security-severity 9.1
 * @precision medium
 * @id py/packet
 * @tags security
 *       external/cwe/cwe-330
 */

import python
import semmle.python.security.dataflow.InsufficientRandomnessQuery
import InsufficientRandomnessFlow::PathGraph

from InsufficientRandomnessFlow::PathNode source, InsufficientRandomnessFlow::PathNode sink
where InsufficientRandomnessFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This value depends on a $@.", source.getNode(),
  "non-cryptographically strong random value"
/**
 * @name CWE-120: Buffer Copy without Checking Size of Input ('Classic Buffer Overflow')
 * @description The product copies an input buffer to an output buffer without verifying that the size of the input buffer is less than the size of the output buffer.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/path-injection
 * @tags correctness
 *       security
 *       external/cwe/cwe-120
 */

import python
import semmle.python.security.dataflow.BufferOverflowQuery
import BufferOverflowFlow::PathGraph

from BufferOverflowFlow::PathNode source, BufferOverflowFlow::PathNode sink
where BufferOverflowFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Buffer copy starts at this point because it depends on a $@.", source.getNode(),
  "user-controlled input."
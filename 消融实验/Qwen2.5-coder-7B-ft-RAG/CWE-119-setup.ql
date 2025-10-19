/**
 * @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 * @description The product performs operations on a memory buffer, but it reads from or writes to a memory location
 *              outside the buffer's intended boundary. This may result in read or write operations on unexpected
 *              memory locations that could be linked to other variables, data structures, or internal program data.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision high
 * @id py/setup
 * @tags security
 *       external/cwe/cwe-119
 */

import python
import semmle.python.security.dataflow.BufferOverflowQuery
import BufferOverflowFlow::PathGraph

from BufferOverflowFlow::PathNode source, BufferOverflowFlow::PathNode sink
where BufferOverflowFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Buffer overflow depends on a $@.", source.getNode(), "user-controlled value"
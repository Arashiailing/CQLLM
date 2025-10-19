/**
 * @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 * @description The product performs operations on a memory buffer, but it reads from or writes to a memory location
 *              outside the buffer's intended boundary. This may result in read or write operations on unexpected memory
 *              locations that could be linked to other variables, data structures, or internal program data.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/pyfribidi
 * @tags security
 *       external/cwe/cwe-119
 */

import python
import experimental.fribidi.FribidiSecurityFlow::PathGraph
from FribidiSecurityFlow::PathNode source, FribidiSecurityFlow::PathNode sink
where FribidiSecurityFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Memory operation performed by $@ could overflow the buffer.", source.getNode(),
  "untrusted input"
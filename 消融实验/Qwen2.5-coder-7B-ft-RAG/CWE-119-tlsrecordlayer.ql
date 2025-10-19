/**
 * @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 * @description The product performs operations on a memory buffer, but it reads from or writes to a memory location
 *              outside the buffer's intended boundary. This may result in read or write operations on unexpected memory
 *              locations that could be linked to other variables, data structures, or internal program data.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision high
 * @id py/tlsrecordlayer
 * @tags external/cwe/cwe-119
 *       security
 *       crypto
 */

import python
import semmle.python.security.dataflow.TLSRecordLayerQuery
import TLSRecordLayerFlow::PathGraph

from TLSRecordLayerFlow::PathNode source, TLSRecordLayerFlow::PathNode sink
where TLSRecordLayerFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "TLS record layer message length depends on a $@", source.getNode(),
  "user-controlled value"
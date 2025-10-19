/**
 * @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 * @description The product performs operations on a memory buffer, but it reads from or writes to a memory location outside the buffer's intended boundary. This may result in read or write operations on unexpected memory locations that could be linked to other variables, data structures, or internal program data.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision high
 * @id py/core-cwe-119
 * @tags correctness
 *       security
 *       external/cwe/cwe-119
 */

import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

from
  PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink, ExternalApiUsedWithUntrustedData externalApi
where
  exists(PathInjectionFlow::PathNode taintedSource |
    taintedSource.getNode() = source.getNode() and
    externalApi = taintedSource.(Sink).getNode().(ExternalApiUsedWithUntrustedData)
  )
  and
  PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Call to " + externalApi.toString() + " with untrusted data from $@.", source.getNode(), externalApi.toString()
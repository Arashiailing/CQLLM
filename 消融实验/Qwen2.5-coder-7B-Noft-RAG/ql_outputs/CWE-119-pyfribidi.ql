/**
* @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
*
@description The product performs operations on a memory buffer, but it reads
from
    or writes to a memory location outside the buffer's intended boundary.
* @kind path-problem
*
@id py/pyfribidi
* @problem.severity error
* @security-severity 7.5
* @precision high
*
@tags security
*/
import python
import semmle.python.security.dataflow.BufferOverreadQuery
import BufferOverreadFlow::PathGraph
from BufferOverreadFlow::PathNode source, BufferOverreadFlow::PathNode sink
    where BufferOverreadFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Buffer over-read at $@.", source.getNode(), "out-of-bounds index"
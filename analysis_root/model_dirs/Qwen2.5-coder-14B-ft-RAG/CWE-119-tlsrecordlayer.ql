/**
 * @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 * @description The product performs operations on a memory buffer, but it reads from or writes to a memory location outside the buffer's intended boundary. This may result in read or write operations on unexpected memory locations that could be linked to other variables, data structures, or internal program data.
 * @kind problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision medium
 * @id py/tlsrecordlayer
 * @tags correctness
 *       security
 *       external/cwe/cwe-119
 */

import python
import semmle.python.Concepts

from TlsRecordLayer::BufferOperation op
where not op.isInTest()
select op, "The operation $@ may access a buffer at index $@.", op, op.getIndex()
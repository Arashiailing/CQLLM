/**
 * @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 * @description The product performs operations on a memory buffer, but it reads from or writes to a memory location outside the buffer's intended boundary.
 * @id py/tlsrecordlayer
 */

import python
import semmle.python.security.dataflow.UnsafeDeserializationQuery

from Call c, String mod, String function
where temporary_name_function(mod, function).getACall().asExpr() = c
select c, "Call to deprecated function " + mod + "." + function + " may be insecure."
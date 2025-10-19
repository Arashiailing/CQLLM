/**
* @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
*
@description The product performs operations on a memory buffer, but it reads
from
    or writes to a memory location outside the buffer's intended boundary.
*
@id py/tlsrecordlayer
*/
import python
import semmle.python.security.dataflow.UnsafeDeserializationQuery
from Call cfgNode, Node arg, string hostname
    where cfgNode = socketInstance().getMember("bind").getACall()
    and arg = cfgNode.getArg(0)
    and arg = vulnerableAddressTuple(hostname)
    select cfgNode.asExpr(), "'" + hostname + "' binds a socket to all interfaces."
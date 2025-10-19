import python
import semmle.code.cpp.dataflow.DataFlow

from MethodInvoke mi, String s, Variable v
where 
  mi.getTarget().getName() = "copy"
  and mi.getArguments()[0].getType().isPointerType()
  and mi.getArguments()[1].getType().isPointerType()
  and exists(Variable v2 | v2.getName() = "size" and v2.getType().isIntegerType())
  and not (exists(Call c | c.getMethodName() = "strlen" and c.getArgument().equals(mi.getArguments()[1])))
select mi, "Potential CWE-120: Buffer copy without checking size of input"
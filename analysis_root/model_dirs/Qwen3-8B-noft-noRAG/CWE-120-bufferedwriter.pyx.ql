import python

/**
 * @name CWE-120: Buffer Copy without Checking Size of Input ('Classic Buffer Overflow')
 */
from Call call, Variable var, StringLiteral str
where call.getTarget().getName() = "list" and call.getMethodName() = "__init__"
   and call.getArguments().size() = 1
   and call.getArgument(0).getExpression().isStringLiteral()
   and call.getReceiver().getName() = var.getName()
   and str.getValue() = call.getArgument(0).getExpression().getValue()
select call.getExpression(), "Potential buffer overflow due to unbounded string-to-list conversion."
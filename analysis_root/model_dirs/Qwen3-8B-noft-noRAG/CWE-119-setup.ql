import python

/**
 * Detect potential out-of-bounds accesses in Python code.
 */
from Call call, Argument arg
where call.getCallee().getName() = "__getitem__"
  and call.getFunction().getModule().getName() = "builtins"
  and arg.getPosition() = 0
  and arg.getType().getKind() = "Sequence"
  and not (arg.getValue().isConstant() and arg.getValue().getIntegerValue() >= 0 and arg.getValue().getIntegerValue() < arg.getType().getLength())
select call, "Potential out-of-bounds access detected"
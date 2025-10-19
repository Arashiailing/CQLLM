import python

/**
 * CWE-476: NULL Pointer Dereference
 * Detects instances where a pointer that is expected to be valid but is NULL is dereferenced.
 */
from Call call, Expr arg
where call.getCallee().getName() = "dereference"
  and arg.getType() instanceof PointerType
  and arg.isNull()
select call, "This call dereferences a NULL pointer."
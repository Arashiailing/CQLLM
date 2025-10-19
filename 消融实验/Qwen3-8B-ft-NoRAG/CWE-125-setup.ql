import python

from Call call, Expr index, Expr container
where call.getTarget() = python.Method("list", "__getitem__") or
      call.getTarget() = python.Method("str", "__getitem__") or
      call.getTarget() = python.Method("tuple", "__getitem__")
and call.getArgs() = [index]
and call.getArg(0) = container
and exists (Call lenCall,
    lenCall.getTarget() = python.Method("builtins", "len"),
    lenCall.getArg(0) = container,
    (index < lenCall) or (index >= lenCall)
)
select call, "Potential out-of-bounds read"
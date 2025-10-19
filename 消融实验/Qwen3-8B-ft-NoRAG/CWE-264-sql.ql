import python

from PyCall call
where call.getMethod().getName() = "execute"
  and call.getArgument(0).getType().isString()
  and (call.getArgument(0).getValue().isConcatenated() or call.getArgument(0).getValue().contains("%s") or call.getArgument(0).getValue().contains("%d") or call.getArgument(0).getValue().contains("%r") or call.getArgument(0).getValue().contains("{}"))
select call
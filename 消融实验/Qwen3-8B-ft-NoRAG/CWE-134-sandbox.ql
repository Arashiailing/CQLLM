import python

from Call call, Argument arg
where call.getMethod().getName() = "format"
  and arg.getIndex() = 0
  and arg.getValue().isExternal()
select call, "Use of externally-controlled format string in format method."
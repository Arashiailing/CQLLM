import python

from Call call, Parameter param
where call.getTarget().getName() = "loads" and call.getTarget().getModule().getName() = "pickle"
  and (param.getIndex() = 0)
  and exists(Source src, DataFlow::Path path |
    DataFlow::getPath(src, param.getValue(), path) and
    src.getType() = SourceType.USER_INPUT or src.getType() = SourceType.NETWORK_INPUT)
select call.getLocation(), "Potential unsafe deserialization using pickle.loads with untrusted input", call
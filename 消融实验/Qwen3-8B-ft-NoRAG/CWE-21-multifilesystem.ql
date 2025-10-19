import python

from Call call, String s
where call.getTarget().getName() = "open" and
      call.getArgument(0) = s and
      s.getValue().contains("../") or
      s.getValue().contains("..\\") or
      s.getValue().contains("/./") or
      s.getValue().contains("\\./")
select call, "Potential Path Injection via unsafe path traversal in file path."
import py

from Call call, Variable var
where (call.getTarget() = "+" and (call.getArgument(0) = var or call.getArgument(1) = var)) or
      (call.getTarget() = "format" and call.getArgument(0) = var)
select call, "Potential reflected XSS due to string manipulation"
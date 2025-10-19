import python

from Call call, Argument arg
where call.getTarget().getName() = "open" and
      arg.getValue().getKind() = "Variable" and
      arg.getValue().getName() = "path" and
      not exists (call.getModule().getName() = "os" and call.getTarget().getName() = "open")
select call, "Potential CWE-59: Improper link resolution in open call"
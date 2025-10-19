import python

from Call call
where call.getCallee().getName() = "open" and
      call.getArgument(0).isStringLiteral() and
      call.getArgument(0).getValue().matches(".*[pP][aA][sS][sS][wW][oO][rR][dD].*")
select call, "CWE-522: Clear text storage of credentials detected in file operations."

from Call call
where call.getCallee().getName() = "log" and
      call.getArgument(0).isStringLiteral() and
      call.getArgument(0).getValue().matches(".*[pP][aA][sS][sS][wW][oO][rR][dD].*")
select call, "CWE-522: Clear text storage of credentials detected in logging."

from Call call
where call.getCallee().getName() = "post" and
      call.getContainer().getName() = "requests" and
      call.getArgument(1).isStringLiteral() and
      call.getArgument(1).getValue().matches(".*[pP][aA][sS][sS][wW][oO][rR][dD].*")
select call, "CWE-522: Clear text transmission of credentials in HTTP requests."
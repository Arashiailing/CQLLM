import py

from Call call, Argument arg
where call.getMethod().getName() = "send_response" and
      call.getModule().getName() = "http.server" and
      arg.getArgumentIndex() = 1 and
      arg.getValue().getValue() = "301" or arg.getValue().getValue() = "302" and
      exists(Argument arg2 | call.getArgument(arg2.getArgumentIndex() = 2) and
             arg2.getValue().getValue().matches("Location: (.*)") and
             arg2.getValue().getValue().getGroup(1).matches("http://.*|https://.*") and
             arg2.getValue().getValue().getGroup(1).isUserInput())
select call, "Potential URL redirection based on unvalidated user input"
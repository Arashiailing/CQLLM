import python

from Call call, StringLiteral url, Argument arg
where call.getCallee().getName() = "redirect" and
      arg = call.getArgument(0) and
      url = arg.getAString() and
      url.getValue().matches("%.*")
select call, "Potentially vulnerable URL redirection detected: " + url.getValue()
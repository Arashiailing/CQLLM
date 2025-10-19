import python

from Call call, String string, Variable var
where 
  (call.getSelector() = "redirect" or call.getSelector() = "send_redirect") and
  exists(
    string in call.getArguments() and
    var in string.getStringLiterals() and
    var.isFromUserInput()
  )
select call, "Potential URL redirection based on unvalidated user input"
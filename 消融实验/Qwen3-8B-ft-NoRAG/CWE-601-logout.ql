import python

from Call c
where c.getCallee().getName() in ["redirect", "send_redirect", "webbrowser.open"]
  and c.getArgument(0).getSymbol().isUserInput()
select c, "Potential URL redirection based on unvalidated user input"
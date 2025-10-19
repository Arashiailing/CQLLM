import py

from Call call
where (
  (call.getFunction().getName() = "redirect" and call.getArgument(0).isUserInput()) or
  (call.getFunction().getName() = "open" and call.getModule().getName() = "webbrowser" and call.getArgument(0).isUserInput()) or
  (call.getFunction().getName() = "get" and call.getModule().getName() = "requests" and call.getArgument(0).isUserInput()) or
  (call.getFunction().getName() = "post" and call.getModule().getName() = "requests" and call.getArgument(0).isUserInput())
)
select call, "Potential URL redirection based on unvalidated user input"
import py

from Call call, Call inputCall, Variable var
where call.getTarget() = py::createMethod("webbrowser", "open")
  and call.getArg(0) = var
  and exists (inputCall where inputCall.getTarget() = py::createMethod("builtins", "input") and inputCall.getArg(0) = var)
select call, "Potential URL redirection vulnerability due to unvalidated user input."
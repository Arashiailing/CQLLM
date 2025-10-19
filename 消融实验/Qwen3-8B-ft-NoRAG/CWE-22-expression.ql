import py

from Call input_call, Call path_call
where input_call.getTarget().getName() = "input"
  and path_call.getArgument(0) = input_call.getReturnValue()
  and path_call.getTarget().getName() in ["open", "os.path.join", "os.path.abspath", "os.path.realpath"]
select path_call, "Potential path injection via user-controlled path expression"
import py

from CallExpr call
where (call.getCallee().getName() = "os.system" or
       (call.getCallee().getName() = "subprocess.run" and
        call.getArgs().hasArg( (arg, name) | name = "shell" and arg.getBoolValue() = true )))
and call.getArgs().hasArg( (arg, _) | arg.getKind() = "py::String" and arg.getExpression().hasUserInput() )
select call, "Potential command injection via os.system or subprocess.run with user input and shell=True"
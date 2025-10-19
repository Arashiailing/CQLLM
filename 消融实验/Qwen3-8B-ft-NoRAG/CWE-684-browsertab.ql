import python

from Call call, Argument arg, UserInputSource source
where (call.getCallee().getName() = "os.system" and arg.getKind() = "Argument" and arg.getExpression() = source.getExpression()) 
   or (call.getCallee().getName() = "subprocess.run" and arg.getKind() = "Argument" and arg.getExpression() = source.getExpression() and call.getArgument("shell").getValue() = true)
select call, "Potential command injection vulnerability due to direct user input in command execution."
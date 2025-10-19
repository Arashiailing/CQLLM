import python

from Call call
where call.getFunction().getName() in ["os.system", "subprocess.call", "subprocess.check_output", "subprocess.run", "subprocess.Popen"]
  and (call.getFunction().getName() = "subprocess.run" and call.getArguments().hasArgument("shell", true))
  or (call.getFunction().getName() = "subprocess.Popen" and call.getArguments().hasArgument("shell", true))
  or (call.getFunction().getName() in ["os.system", "subprocess.call", "subprocess.check_output"] and call.getArguments().size() > 0
      and exists (Arg arg | call.getArguments().hasArg(arg) and arg.getType().isString()
                  and arg.getExpression().containsUserInput()))
select call, "Potential Command Injection via command execution function with user input."
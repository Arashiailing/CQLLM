import py

from Call call
where call.getFunction().getName() in ("subprocess.run", "os.system", "subprocess.call", "subprocess.Popen", "subprocess.check_output", "subprocess.communicate")
  and call.getArguments().any(arg | arg.getType().isString() and arg.getExpression().isUserInput())
select call, "Potential command injection due to improper input validation."
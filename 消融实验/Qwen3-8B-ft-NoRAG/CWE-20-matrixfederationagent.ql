import python

from Call inputCall, Call call, Argument arg
where inputCall.getFunction().getName() = "input"
  and call.getFunction().getName() in ["eval", "exec", "os.system", "subprocess.run", "os.popen", "subprocess.check_output"]
  and arg.getValue().getVariable().getName() = inputCall.getVariable().getName()
select call, "Improper input validation: Unvalidated input passed to dangerous function"
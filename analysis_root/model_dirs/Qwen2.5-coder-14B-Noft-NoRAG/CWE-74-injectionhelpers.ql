import python

/**
 * CWE-74: Command Injection
 */
from Call call, Function func, DataFlow::Node src, DataFlow::Node sink
where func.getName() = "subprocess.call" or func.getName() = "os.system"
  and call.getCallee() = func
  and DataFlow::localFlow(src, sink)
  and src instanceof Expr
  and sink instanceof Call
select src, "This input is used to construct a command that is executed, which could lead to command injection."
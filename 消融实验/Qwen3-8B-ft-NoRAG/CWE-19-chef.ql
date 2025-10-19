import python
import dataFlow

from Call call, String str
where call.getCallee().getName() in ["os.system", "subprocess.run", "subprocess.call", "subprocess.check_output", "subprocess.Popen"]
and call.getArg(0) = str
and exists (DataFlow::source src where src.getExpression() = str)
select call, "Potential command injection vulnerability due to unvalidated user input."
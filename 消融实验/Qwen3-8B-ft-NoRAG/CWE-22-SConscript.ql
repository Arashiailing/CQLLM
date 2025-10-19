```ql
import python

from PyFunctionCall call, PyVariableAccess var
where call.getFunction().getName() in ["open", "os.path.join", "os.system", "subprocess.run"]
  and call.getArgument(0) = var
  and (exists (PyFunctionCall inputCall where inputCall.getFunction().getName() = "input" and inputCall.getArgument(0) = var) or
       exists (PyFunctionCall argvCall where argvCall.getFunction().getName() = "sys.argv" and
               PyListAccess listAccess where listAccess.getList() = argvCall and
               listAccess.getIndex() = 0 and
               listAccess.getAccessedVariable() = var
import python
import semmle.code.cpp.dataflow.DataFlow

// Define a predicate to find path construction operations with user input
predicate isPathConstruction(FunctionCall call) {
  // Check for os.path.join calls with user-controlled arguments
  (call.getFunction().getName() = "join" and 
   call.getModule().getName() = "os.path") or
  
  // Check for pathlib.Path concatenation using / operator
  (call.getFunction().getName() = "__mul__" and 
   call.getModule().getName() = "pathlib" and 
   exists(StringLiteral s | call.getArg(0).getValue() = s and s.getValue() = "/"))
}

// Define a predicate to identify potential sinks where constructed paths are used
predicate isPathSink(CallSite site) {
  // Check for file open operations with constructed paths
  site.getMethodName() = "open" or
  site.getMethodName() = "read" or
  site.getMethodName() = "write" or
  site.getMethodName() = "exec"
}

from FunctionCall call, CallSite site
where isPathConstruction(call) and 
      dataFlow::isDataFlowFromUserInputToTarget(call, site)
select site, "Potential Path Injection vulnerability detected through path construction and usage of user-controlled input."
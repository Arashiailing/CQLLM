import python

from Call call, Argument arg, FunctionDecl func
where 
  func.getName() = "print" and 
  exists (arg, call.getArgument(arg) = arg) and 
  isUserInput(arg.getValue()) and 
  call.getCallee().getFilePath()!= null
select call, "Potential reflected XSS due to direct output of untrusted data."
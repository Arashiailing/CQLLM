import python

from Call call, StringLiteral strLit, Variable var
where call.getCallee().getName() in ["subprocess.run", "subprocess.check_call", "subprocess.call", 
                                     "subprocess.Popen", "os.system", "os.exec*"] 
  and call.getArgument(0) = strLit
  and exists (var, DataFlow::uses(var, strLit))
select call.getLocation(), "Potential unsafe shell command construction detected"
import python
import semmle.code.cpp.callgraph.CallGraph
import semmle.code.cpp.dataflow.DataFlow

/**
 * @name Uncontrolled data used in path expression
 * @description Accessing paths influenced by users can allow an attacker to access unexpected resources.
 * @id py/verify
 */

from MethodCall call, Parameter param, Expression expr
where 
  call.getMethod().getName() = "open" or 
  call.getMethod().getName() = "read" or 
  call.getMethod().getName() = "write" or 
  call.getMethod().getName() = "exec" or 
  call.getMethod().getName() = "pathlib.Path" or 
  call.getMethod().getName() = "os.path.join"

  and 
  (param.getArg(0).getType().isString() or param.getArg(1).getType().isString()) 

  and 
  exists(Source src, Sink sink | 
    DataFlow::hasPath(src, sink, param.getArg(0), call) or 
    DataFlow::hasPath(src, sink, param.getArg(1), call)
  )

select call, "Uncontrolled data used in path expression: Potential path injection vulnerability detected."
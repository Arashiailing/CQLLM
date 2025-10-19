/** @name CWE-400: Uncontrolled Resource Consumption */
import python
import semmle.python.security.dataflow.UncontrolledResourceConsumptionQuery

from Call call
where call.getDecl().getName() = "open" and
      not exists(Call closeCall | 
          closeCall.getDecl().getName() = "close" and
          closeCall.getCallsite().getLocation().getFile() = call.getCallsite().getLocation().getFile() and
          closeCall.getCallsite().getLocation().getLine() > call.getCallsite().getLocation().getLine()
      )
select call, "Potential uncontrolled resource consumption: open without close"
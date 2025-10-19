import python
import semmle.code.cpp.dataflow.DataFlow

from Call call, String exceptionType
where call.getName() = "raise" and
      call.getArgument(0).getType().getName() = "Exception"
select call, "Potential incorrect exception handling: raising base Exception class without specific type."
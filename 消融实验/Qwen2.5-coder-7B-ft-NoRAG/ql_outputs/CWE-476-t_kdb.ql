python
import python
import semmle.python.security.dataflow.StackTraceExposureQuery

from Call call, ExceptionValue exwhere call.getFunc().pointsTo(ex) and ex.isThrown()

select call, "Potential stack trace exposure due to thrown exception."
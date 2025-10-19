import python
import semmle.python.security.dataflow.UncontrolledResourceConsumptionQuery
from PathNode source, PathNode sink
    where UncontrolledResourceConsumptionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Resource consumption is not controlled by a $@.", source.getNode(), "uncontrolled value"
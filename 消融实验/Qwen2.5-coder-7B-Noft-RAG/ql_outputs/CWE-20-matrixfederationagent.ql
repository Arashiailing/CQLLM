import python
import semmle.python.security.dataflow.InsecureInputValidationQuery
import InsecureInputValidationFlow::PathGraph
from InsecureInputValidationFlow::PathNode source, InsecureInputValidationFlow::PathNode sink
    where InsecureInputValidationFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Improper input validation depends on a $@.", source.getNode(), "user-supplied input"
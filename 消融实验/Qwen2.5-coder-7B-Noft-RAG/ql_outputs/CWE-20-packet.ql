import python
import semmle.python.security.dataflow.InsecureInputValidationQuery
import InsecureInputValidationFlow::PathGraph
from InsecureInputValidationFlow::PathNode source, InsecureInputValidationFlow::PathNode sink
    where InsecureInputValidationFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Input validation failure at $@.", source.getNode(), "user-supplied data"
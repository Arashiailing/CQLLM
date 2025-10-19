import python
import semmle.python.security.dataflow.StringUtilsQuery
import StringUtilsFlow::PathGraph
from StringUtilsFlow::PathNode source, StringUtilsFlow::PathNode sink
    where StringUtilsFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Input validation is missing
    or incorrect f
    or the string."
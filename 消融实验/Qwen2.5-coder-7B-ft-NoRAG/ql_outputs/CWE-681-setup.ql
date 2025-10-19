import python
import semmle.python.security.dataflow.NanConversionQuery

from NanConversionFlow::PathNode source, NanConversionFlow::PathNode sink
where NanConversionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "NAN conversion error"
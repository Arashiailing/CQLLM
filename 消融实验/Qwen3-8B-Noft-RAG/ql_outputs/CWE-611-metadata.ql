@name XML external entity expansion
@id py/metadata
@kind path-problem
@problem.severity error
@security-severity 9.1
@precision high
import python
import semmle.python.security.dataflow.XxeQuery
import XxeFlow::PathGraph

from XxeFlow::PathNode source, XxeFlow::PathNode sink
where XxeFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "XML parsing depends on a $@ without guarding against external entity expansion.", source.getNode(), "user-provided value"
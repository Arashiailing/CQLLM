import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink, PathInjectionFlow::PathNode sinkNode
where
  PathInjectionFlow::flowPath(source, sink) and
  sinkNode = sink
select sinkNode.getNode(), source, sink, "Call to " + sinkNode.toString() + " with untrusted data from $@.", source.getNode(), source.toString()
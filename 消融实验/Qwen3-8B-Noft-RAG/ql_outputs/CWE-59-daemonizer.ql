import python
import experimental.Security.UnsafeUnpackQuery
import UnsafeUnpackFlow::PathGraph

from UnsafeUnpackFlow::PathNode source, UnsafeUnpackFlow::PathNode sink
where UnsafeUnpackFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Extraction of tarfile from $@ to a potentially untrusted source $@.", source.getNode(), source.getNode().toString(), sink.getNode(), sink.getNode().toString()
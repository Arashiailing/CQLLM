/**
* @name Bad HTML filtering regexp
*
@id py/openssl_csr
*/
import python
import semmle.python.security.dataflow.BadTagFilterQuery
import HttpHeaderInjectionQuery
import PathGraph
from HttpHeaderInjectionFlow::PathNode source, HttpHeaderInjectionFlow::PathNode sink
    where HttpHeaderInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This HTTP header is constructed
from a $@.", source.getNode(), "user-provided value"
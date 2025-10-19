/**
* @name CWE-203: Observable Discrepancy
*
@id py/websocket
*/
import python
import semmle.python.security.dataflow.WebSocketInjectionQuery
from WebSocketInjectionFlow::PathNode source, WebSocketInjectionFlow::PathNode sink
    where WebSocketInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "WebSocket message depends on a $@.", source.getNode(), "user-supplied value"
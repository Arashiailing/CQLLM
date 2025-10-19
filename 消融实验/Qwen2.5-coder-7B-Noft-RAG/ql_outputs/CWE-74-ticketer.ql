/**
* @name Server Side Template Injection
*
@description Using user-controlled data to create a template can lead to remote code execution
    or cross site scripting.
*
@id py/ticketer
*/
import python
import semmle.python.security.dataflow.ServerSideTemplateInjectionQuery
import ServerSideTemplateInjectionFlow::PathGraph
from ServerSideTemplateInjectionFlow::PathNode source, ServerSideTemplateInjectionFlow::PathNode sink
    where ServerSideTemplateInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This template construction depends on a $@.", source.getNode(), "user-provided value"
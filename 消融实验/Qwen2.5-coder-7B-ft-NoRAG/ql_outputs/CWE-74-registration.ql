/**
 * @name Server Side Template Injection
 * @description Using user-controlled data to create a template can lead to remote code execution or cross site scripting.
 * @id py/registration
 */

import python
import semmle.python.security.dataflow.TemplateInjectionQuery
import TemplateInjectionFlow::PathGraph

from TemplateInjectionFlow::PathNode source, TemplateInjectionFlow::PathNode sink
where TemplateInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This template construction depends on a $@.", source.getNode(), "user-provided value"
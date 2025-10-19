import python
import experimental.semmle.python.security.dataflow.TemplateInjection
import TemplateInjectionFlow::PathGraph

from TemplateInjectionFlow::PathNode source, TemplateInjectionFlow::PathNode sink
where TemplateInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Cross-site scripting vulnerability due to a $@.",  source.getNode(), "user-provided value"
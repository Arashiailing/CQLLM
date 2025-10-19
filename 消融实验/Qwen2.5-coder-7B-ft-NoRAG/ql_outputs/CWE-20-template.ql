/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does not validate or incorrectly validates that the input has the properties that are required to process the data safely and correctly.
 * @id py/template
 */

import python
import semmle.python.security.dataflow.TemplateInjectionQuery
import TemplateInjectionFlow::PathGraph

from TemplateInjectionFlow::PathNode source, TemplateInjectionFlow::PathNode sink
where TemplateInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This template construction depends on a $@.", source.getNode(), "user-provided value"
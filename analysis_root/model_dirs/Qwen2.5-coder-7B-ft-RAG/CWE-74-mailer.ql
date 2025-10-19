/**
 * @name Server Side Template Injection
 * @description Using user-controlled data to create a template can lead to remote code execution or cross site scripting.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @security-severity 9.3
 * @id py/mailer
 * @tags security
 *       external/cwe/cwe-074
 */

import python
import semmle.python.security.dataflow.ServerSideTemplateInjectionQuery
import ServerSideTemplateInjectionFlow::PathGraph
from ServerSideTemplateInjectionFlow::PathNode source, ServerSideTemplateInjectionFlow::PathNode sink
where ServerSideTemplateInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This template construction depends on a $@.", source.getNode(), "user-provided value"
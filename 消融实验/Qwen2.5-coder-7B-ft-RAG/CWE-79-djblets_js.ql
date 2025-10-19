/**
 * @name Django JS Injection
 * @description Writing user-supplied data into client-side scripts without proper escaping may enable a JS injection attack.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision medium
 * @id py/djblets_js
 * @tags security
 *       external/cwe/cwe-079
 */

import javascript
import semmle.python.security.dataflow.DjbletsJsInjectionQuery
import DjbletsJsInjectionFlow::PathGraph
from DjbletsJsInjectionFlow::PathNode source, DjbletsJsInjectionFlow::PathNode sink
where DjbletsJsInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Django constructs a JavaScript string with this $@.", source.getNode(), "user-controlled value"
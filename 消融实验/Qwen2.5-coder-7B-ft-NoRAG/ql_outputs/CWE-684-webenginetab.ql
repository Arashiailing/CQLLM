/**
 * @name CWE-684: Incorrect Provision of Specified Functionality
 * @id py/webenginetab
 */

import python
import semmle.python.security.dataflow.UrlRedirectQuery

from UrlRedirectFlow::PathNode source, UrlRedirectFlow::PathNode sink
where UrlRedirectFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Incorrect provision of specified functionality via URL redirection."
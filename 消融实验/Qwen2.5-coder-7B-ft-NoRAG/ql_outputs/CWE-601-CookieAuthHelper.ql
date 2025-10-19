/**
 * @name URL redirection from remote source
 * @description URL redirection based on unvalidated user input
 * may cause redirection to malicious web sites.
 * @id py/CookieAuthHelper
 */

import python
import semmle.python.security.dataflow.UrlRedirectQuery
import UrlRedirectFlow::PathGraph

from UrlRedirectFlow::PathNode source, UrlRedirectFlow::PathNode sink
where UrlRedirectFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Untrusted URL redirection depends on a $@.", source.getNode(),  "user-provided value"
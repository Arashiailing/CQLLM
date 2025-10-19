/**
 * @name Regex Injection Query
 * @category Permissions, Privileges, and Access Controls
 * @description Regex injection occurs when user input is used in a regular expression without proper validation.
 * @id py/regex-injection
 */

import python
import semmle.python.security.dataflow.RegexInjectionQuery
import RegexInjectionFlow::PathGraph

from RegexInjectionFlow::PathNode source, RegexInjectionFlow::PathNode sink
where RegexInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Regular expression depends on a $@.", source.getNode(), "user-supplied input"
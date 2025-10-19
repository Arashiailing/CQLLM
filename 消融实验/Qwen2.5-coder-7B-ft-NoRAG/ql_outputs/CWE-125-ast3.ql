/**
 * @name CWE-125: Path Injection
 * @description The product reads data past the end, or before the beginning, of the intended buffer.
 * @id py/path-injection
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 */

import python

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(), "user-provided value"
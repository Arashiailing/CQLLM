/**
 * @name CWE-269: Improper Privilege Management
 * @description The product does not properly assign, modify, track, or check privileges for an actor, creating an unintended sphere of control for that actor.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @sub-severity high
 * @precision high
 * @id py/autojump
 * @tags security
 *       external/cwe/cwe-269
 */

import python
import semmle.python.security.dataflow.CommandInjectionQuery
import CommandInjectionFlow::PathGraph

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper privilege management detected at $@.", source.getNode(), "user-provided value"
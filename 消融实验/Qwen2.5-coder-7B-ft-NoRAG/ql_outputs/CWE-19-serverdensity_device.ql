/**
 * @name CWE-19: Command Injection Query
 * @description Detection of command injection vulnerabilities
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/command-injection
 * @tags security
 *       external/cwe/cwe-19
 */

import python
import semmle.python.security.dataflow.CommandInjectionQuery
import CommandInjectionFlow::PathGraph

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This command line depends on a $@.", source.getNode(), "user-provided value"
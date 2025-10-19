/**
* @name Improper Neutralization of Special Elements used in an OS Command ('OS Command Injection')
* @description Execution of a system command with untrusted data as an argument allows injection of additional commands.
* @kind path-problem
* @problem.severity error
* @security-severity 9.8
* @precision high
* @id py/command-line-injection
* @tags correctness
*       security
*       external/cwe/cwe-078
*       external/cwe/cwe-088
*/

import python
import semmle.python.security.dataflow.CommandInjectionQuery
import CommandInjectionFlow::PathGraph

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This command line depends on a $@.", source.getNode(), "user-provided value"
/**
 * @name CWE CATEGORY: Permissions, Privileges, and Access Controls
 * @description nan
 * @kind problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision high
 * @id py/core-cwe-264
 * @tags security
 */

import python
import semmle.python.security.dataflow.CommandInjectionQuery
import semmle.python.Concepts

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "$@ reaches a command injection sink.", source.getNode(),
  "User-provided value"
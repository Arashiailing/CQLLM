/**
 * @name Externally controlled format string usage
 * @description The product uses a function that accepts a format string as an argument, but the format string originates from an external source. 
 *              This pattern is susceptible to format string vulnerabilities, potentially leading to arbitrary code execution.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @sub-severity high
 * @precision medium
 * @id py/externally-controlled-format-string
 * @tags security
 *       external/cwe/cwe-134
 */

import python
import semmle.python.security.dataflow.LogInjectionQuery
import LogInjectionFlow::PathGraph

from LogInjectionFlow::PathNode source, LogInjectionFlow::PathNode sink
where LogInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This %1 depends on a $@.", source.getNode(), "user-provided value", 
  source.getNode(), source.getNode().(StringLiteral).getText()
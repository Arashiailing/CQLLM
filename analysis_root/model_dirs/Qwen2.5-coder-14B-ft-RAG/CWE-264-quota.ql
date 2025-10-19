/**
 * @name CWE-78: Improper Neutralization of Special Elements used in an OS Command ('OS Command Injection')
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @sub-severity high
 * @precision high
 * @id py/command-line-injection
 * @tags correctness
 *       security
 *       external/cwe/cwe-078
 *       external/cwe/cwe-088
 */

// Import Python language support
import python

// Import specialized module for detecting OS command injection vulnerabilities
import semmle.python.security.dataflow.CommandInjectionQuery

// Import path graph utilities for visualizing data flow paths
import CommandInjectionFlow::PathGraph

// Define variables for tracking data flow origin (source) and destination (sink)
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink

// Filter results where there is a complete data flow path from source to sink
where CommandInjectionFlow::flowPath(source, sink)

// Select sink node, source node, sink node again, and generate descriptive message
select sink.getNode(), source, sink,
  "This command line depends on a $@.",  // Message format string
  source.getNode(),                     // Source node reference
  "user-provided value"                 // Description of tainted input
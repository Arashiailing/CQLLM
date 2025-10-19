/**
 * @name Regex Injection
 * @description Injection flaws occur when untrusted data is treated as part of a regular expression,
 *              allowing attackers to manipulate its behavior.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/regex
 * @tags security
 *       external/cwe/cwe-400
 *       external/cwe/cwe-730
 */

// Import the necessary module for regex injection analysis
import python
import semmle.python.security.dataflow.RegexInjectionQuery

// Define the path graph class for tracking data flow paths
import RegexInjectionFlow::PathGraph

// Identify source nodes and sink nodes for data flow analysis
from RegexInjectionFlow::PathNode source, RegexInjectionFlow::PathNode sink

// Ensure there is a complete data flow path between source and sink
where RegexInjectionFlow::flowPath(source, sink)

// Select the results including sink node, source node, path details, and description
select sink.getNode(), source, sink, "This regex pattern depends on a $@.", source.getNode(),
       "user-provided value"
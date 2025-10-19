/**
 * @name Command injection vulnerability
 * @description Using untrusted data to create a command line may allow a malicious
 *              user to change the meaning of the command. This query detects command
 *              injection vulnerabilities where user-controlled input flows into system calls.
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

// Import the Python library for code analysis
import python
// Import the CommandInjectionQuery module which provides functionality for detecting command injection vulnerabilities
import semmle.python.security.dataflow.CommandInjectionQuery
// Import the CommandInjectionFlow::PathGraph class which represents the flow graph for command injection analysis
import CommandInjectionFlow::PathGraph

// Define the source and sink nodes for data flow analysis
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
// Filter for paths that have a data flow from the source to the sink
where CommandInjectionFlow::flowPath(source, sink)
// Output the sink node, source node, path information, and description
select sink.getNode(), source, sink, "This command line depends on a $@.", source.getNode(),
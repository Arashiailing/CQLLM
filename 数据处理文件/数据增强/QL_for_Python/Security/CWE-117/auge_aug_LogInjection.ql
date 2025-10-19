/**
 * @name Log Injection Vulnerability
 * @description Identifies log injection flaws where unsanitized user input
 *              is written to log entries, enabling attackers to forge
 *              or manipulate log content through malicious input.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision medium
 * @id py/log-injection
 * @tags security
 *       external/cwe/cwe-117
 */

// Core Python analysis module for source code processing
import python

// Security data flow module specialized in log injection detection
import semmle.python.security.dataflow.LogInjectionQuery

// Path graph implementation for log injection data flow tracking
import LogInjectionFlow::PathGraph

// Query to trace data flow from untrusted sources to vulnerable log sinks
from LogInjectionFlow::PathNode sourceNode, LogInjectionFlow::PathNode sinkNode
where LogInjectionFlow::flowPath(sourceNode, sinkNode)
// Output vulnerable sink node, data flow path components, and vulnerability description
select sinkNode.getNode(), 
       sourceNode, 
       sinkNode, 
       "This log entry incorporates a $@.", 
       sourceNode.getNode(), 
       "user-provided value"
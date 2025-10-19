/**
 * @name Log Injection Vulnerability
 * @description Identifies potential log injection vulnerabilities where untrusted user input
 *              is directly embedded into log entries without sanitization, enabling
 *              attackers to forge log entries or manipulate log content.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision medium
 * @id py/log-injection
 * @tags security
 *       external/cwe/cwe-117
 */

// Import Python analysis library for source code parsing and processing
import python

// Import security data flow module specialized in log injection detection
import semmle.python.security.dataflow.LogInjectionQuery

// Import path graph modeling class for log injection data flow analysis
import LogInjectionFlow::PathGraph

// Identify vulnerable log injection paths from untrusted sources to log sinks
from LogInjectionFlow::PathNode sourceNode, LogInjectionFlow::PathNode sinkNode
where LogInjectionFlow::flowPath(sourceNode, sinkNode)
// Output vulnerable log entry with source-to-sink path and contextual message
select sinkNode.getNode(), sourceNode, sinkNode, 
       "This log entry incorporates a $@.", sourceNode.getNode(), 
       "user-provided value"
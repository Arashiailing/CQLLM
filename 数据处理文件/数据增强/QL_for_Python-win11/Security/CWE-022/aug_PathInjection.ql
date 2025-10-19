/**
 * @name Path expression using uncontrolled data
 * @description User-controlled data in path expressions may enable attackers to access unintended resources.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @sub-severity high
 * @precision high
 * @id py/path-injection
 * @tags correctness
 *       security
 *       external/cwe/cwe-022
 *       external/cwe/cwe-023
 *       external/cwe/cwe-036
 *       external/cwe/cwe-073
 *       external/cwe/cwe-099
 */

// Import Python analysis library
import python

// Import path injection security analysis module
import semmle.python.security.dataflow.PathInjectionQuery

// Import path node definitions from injection flow graph
import PathInjectionFlow::PathGraph

// Identify untrusted data sources and dangerous path sinks
from PathInjectionFlow::PathNode untrustedSource, PathInjectionFlow::PathNode dangerousSink

// Verify data flow exists between source and sink
where PathInjectionFlow::flowPath(untrustedSource, dangerousSink)

// Report findings with source context and warning message
select dangerousSink.getNode(), 
       untrustedSource, 
       dangerousSink, 
       "This path depends on a $@.", 
       untrustedSource.getNode(), 
       "user-provided value"
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

// Core analysis modules
import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

// Identify malicious data sources and vulnerable path sinks
from PathInjectionFlow::PathNode maliciousSource, PathInjectionFlow::PathNode vulnerableSink
where PathInjectionFlow::flowPath(maliciousSource, vulnerableSink)

// Report security findings with contextual details
select vulnerableSink.getNode(), 
       maliciousSource, 
       vulnerableSink, 
       "This path depends on a $@.", 
       maliciousSource.getNode(), 
       "user-provided value"
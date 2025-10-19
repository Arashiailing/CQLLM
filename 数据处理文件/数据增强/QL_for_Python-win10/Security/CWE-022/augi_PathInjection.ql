/**
 * @name Uncontrolled data used in path expression
 * @description Detects when user-controlled input influences file system paths,
 *              potentially enabling unauthorized resource access.
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

// Core Python language support for code analysis
import python

// Path injection detection framework with data flow tracking
import semmle.python.security.dataflow.PathInjectionQuery

// Path graph representation for vulnerability flow modeling
import PathInjectionFlow::PathGraph

// Identify vulnerable path operations where tainted data reaches sensitive sinks
from PathInjectionFlow::PathNode taintedSource, PathInjectionFlow::PathNode vulnerableSink

// Verify data flow propagation from untrusted input to dangerous path operation
where PathInjectionFlow::flowPath(taintedSource, vulnerableSink)

// Report vulnerability with contextual information about the tainted source
select vulnerableSink.getNode(), 
       taintedSource, 
       vulnerableSink, 
       "This path depends on a $@.", 
       taintedSource.getNode(), 
       "user-provided value"
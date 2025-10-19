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

// Core imports for Python security analysis
import python

// Path injection analysis module for detecting tainted data flows
import semmle.python.security.dataflow.PathInjectionQuery

// Path graph definitions for tracking data propagation
import PathInjectionFlow::PathGraph

// Identify potential path injection vulnerabilities by analyzing data flow
// from untrusted sources to dangerous sinks in file path operations
from PathInjectionFlow::PathNode taintedSource, PathInjectionFlow::PathNode pathVulnerability
where PathInjectionFlow::flowPath(taintedSource, pathVulnerability)

// Generate security alert with source and sink context information
select pathVulnerability.getNode(), 
       taintedSource, 
       pathVulnerability, 
       "This path depends on a $@.", 
       taintedSource.getNode(), 
       "user-provided value"
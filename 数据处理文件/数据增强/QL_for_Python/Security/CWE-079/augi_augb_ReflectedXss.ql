/**
 * @name Reflected server-side cross-site scripting
 * @description Identifies security vulnerabilities where untrusted user input is directly
 *              rendered in web pages without proper sanitization, enabling attackers to
 *              execute malicious scripts through reflected data flows.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @sub-severity high
 * @precision high
 * @id py/reflective-xss
 * @tags security
 *       external/cwe/cwe-079
 *       external/cwe/cwe-116
 */

// Import core Python analysis framework
import python
// Import specialized module for detecting reflected cross-site scripting vulnerabilities
import semmle.python.security.dataflow.ReflectedXssQuery
// Import path graph module for visualizing complete data flow trajectories
import ReflectedXssFlow::PathGraph

// Define data flow analysis tracking untrusted input to dangerous web outputs
from ReflectedXssFlow::PathNode taintedSource, ReflectedXssFlow::PathNode vulnerableSink
// Validate complete data flow propagation exists between source and sink
where ReflectedXssFlow::flowPath(taintedSource, vulnerableSink)
// Report security vulnerability with source/sink context and detailed description
select vulnerableSink.getNode(), taintedSource, vulnerableSink, 
       "Cross-site scripting vulnerability originating from $@.", 
       taintedSource.getNode(), "untrusted user input"
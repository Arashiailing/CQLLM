/**
 * @name Reflected server-side cross-site scripting
 * @description Detects vulnerabilities where user input is directly output to web pages,
 *              enabling cross-site scripting attacks through reflected data flows.
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

// Import Python analysis library
import python
// Import specialized query module for reflected cross-site scripting detection
import semmle.python.security.dataflow.ReflectedXssQuery
// Import path graph module for data flow visualization
import ReflectedXssFlow::PathGraph

// Identify vulnerable data flows from untrusted sources to dangerous outputs
// The query traces complete paths where user-controlled input propagates to web page rendering
from ReflectedXssFlow::PathNode untrustedInputSource, ReflectedXssFlow::PathNode outputSink
where ReflectedXssFlow::flowPath(untrustedInputSource, outputSink)
// Report vulnerability with source/sink details and context description
select outputSink.getNode(), untrustedInputSource, outputSink, 
       "Cross-site scripting vulnerability from $@.", 
       untrustedInputSource.getNode(), "untrusted user input"
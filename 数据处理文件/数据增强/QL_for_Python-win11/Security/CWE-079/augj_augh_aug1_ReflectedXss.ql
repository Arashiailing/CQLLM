/**
 * @name Reflected server-side cross-site scripting
 * @description Detects security vulnerabilities where untrusted user input
 *              is directly rendered in web responses without adequate
 *              sanitization, potentially enabling XSS attacks.
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

// Import core Python analysis capabilities
import python
// Import specialized XSS vulnerability detection framework
import semmle.python.security.dataflow.ReflectedXssQuery
// Import path visualization components for data flow analysis
import ReflectedXssFlow::PathGraph

// Define input source and output sink nodes for vulnerability tracking
from ReflectedXssFlow::PathNode inputSource, ReflectedXssFlow::PathNode outputSink

// Establish the condition that a complete data flow path exists
// between the identified input source and output sink
where ReflectedXssFlow::flowPath(inputSource, outputSink)

// Report the identified vulnerability with detailed flow path information
select outputSink.getNode(), 
       inputSource, 
       outputSink, 
       "Cross-site scripting vulnerability due to a $@.", 
       inputSource.getNode(), 
       "user-provided value"
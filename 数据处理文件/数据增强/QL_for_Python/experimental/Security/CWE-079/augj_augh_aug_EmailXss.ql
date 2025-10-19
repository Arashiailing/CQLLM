/**
 * @name Reflected server-side cross-site scripting
 * @description Direct output of user-supplied data to web pages
 *              creates cross-site scripting vulnerabilities.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 2.9
 * @sub-severity high
 * @id py/reflective-xss-email
 * @tags security
 *       experimental
 *       external/cwe/cwe-079
 *       external/cwe/cwe-116
 */

// Core Python analysis framework
import python

// Experimental email XSS dataflow analysis module
import experimental.semmle.python.security.dataflow.EmailXss

// Path visualization components
import EmailXssFlow::PathGraph

// Detect vulnerable data flow paths from user input to dangerous output
from EmailXssFlow::PathNode inputSource, EmailXssFlow::PathNode outputSink
where EmailXssFlow::flowPath(inputSource, outputSink)

// Generate vulnerability report with source-sink correlation
select outputSink.getNode(), 
       inputSource, 
       outputSink, 
       "Cross-site scripting vulnerability via $@.",
       inputSource.getNode(), 
       "User-controlled input"
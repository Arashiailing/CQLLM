/**
 * @name Server Side Template Injection
 * @description Detects potential security vulnerabilities where user-controlled data
 *              is used in template rendering, which may lead to remote code execution
 *              or cross-site scripting attacks.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @security-severity 9.3
 * @id py/template-injection
 * @tags security
 *       external/cwe/cwe-074
 */

// Import Python language support
import python
// Import template injection dataflow analysis module
import semmle.python.security.dataflow.TemplateInjectionQuery
// Import path graph representation for dataflow paths
import TemplateInjectionFlow::PathGraph

// Identify vulnerable template construction paths
from TemplateInjectionFlow::PathNode inputSource, TemplateInjectionFlow::PathNode targetSink
// Verify data flows from untrusted input to template rendering
where TemplateInjectionFlow::flowPath(inputSource, targetSink)
// Generate security alert with source-to-sink path details
select targetSink.getNode(), 
       inputSource, 
       targetSink, 
       "Template construction incorporates $@.",
       inputSource.getNode(), 
       "user-controlled input"
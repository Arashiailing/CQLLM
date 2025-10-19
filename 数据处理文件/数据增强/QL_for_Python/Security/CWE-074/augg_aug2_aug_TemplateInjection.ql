/**
 * @name Server Side Template Injection
 * @description Identifies security flaws where external user input is directly embedded in template rendering, potentially enabling remote code execution or XSS attacks.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @security-severity 9.3
 * @id py/template-injection
 * @tags security
 *       external/cwe/cwe-074
 */

// Core Python language analysis framework
import python
// Template injection vulnerability detection module
import semmle.python.security.dataflow.TemplateInjectionQuery
// Data flow path visualization support
import TemplateInjectionFlow::PathGraph

// Locate tainted input origin and vulnerable template processing point
from TemplateInjectionFlow::PathNode maliciousInput, TemplateInjectionFlow::PathNode templateSink
// Validate data propagation path exists between input and sink
where TemplateInjectionFlow::flowPath(maliciousInput, templateSink)
// Generate vulnerability report with execution flow details
select 
  templateSink.getNode(), 
  maliciousInput, 
  templateSink, 
  "Template rendering incorporates untrusted $@.", 
  maliciousInput.getNode(), 
  "user-controlled input"
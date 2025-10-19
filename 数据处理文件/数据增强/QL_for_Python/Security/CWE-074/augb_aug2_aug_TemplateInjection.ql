/**
 * @name Server Side Template Injection
 * @description Identifies vulnerabilities where user-controlled data flows into template rendering, potentially enabling remote code execution or cross-site scripting attacks.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @security-severity 9.3
 * @id py/template-injection
 * @tags security
 *       external/cwe/cwe-074
 */

// Core Python language support
import python
// Template injection vulnerability analysis
import semmle.python.security.dataflow.TemplateInjectionQuery
// Data flow path graph representation
import TemplateInjectionFlow::PathGraph

// Define tainted input source and vulnerable template sink
from TemplateInjectionFlow::PathNode maliciousInputSource, TemplateInjectionFlow::PathNode templateInjectionSink
// Validate data flow path between source and sink
where TemplateInjectionFlow::flowPath(maliciousInputSource, templateInjectionSink)
// Generate vulnerability report with flow details
select 
  templateInjectionSink.getNode(), 
  maliciousInputSource, 
  templateInjectionSink, 
  "This template construction incorporates a $@.", 
  maliciousInputSource.getNode(), 
  "user-controlled input"
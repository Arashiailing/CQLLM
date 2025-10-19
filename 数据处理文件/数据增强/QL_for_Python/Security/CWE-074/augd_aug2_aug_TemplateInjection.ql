/**
 * @name Server Side Template Injection
 * @description Detects vulnerabilities where untrusted user input is directly embedded into template rendering contexts, enabling attackers to inject malicious templates that may result in remote code execution or cross-site scripting.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @security-severity 9.3
 * @id py/template-injection
 * @tags security
 *       external/cwe/cwe-074
 */

// Core Python language analysis capabilities
import python
// Specialized template injection vulnerability detection
import semmle.python.security.dataflow.TemplateInjectionQuery
// Path visualization components for data flow analysis
import TemplateInjectionFlow::PathGraph

// Identify malicious input sources and vulnerable template sinks
from TemplateInjectionFlow::PathNode maliciousInputSource, TemplateInjectionFlow::PathNode templateInjectionSink
// Validate complete data flow propagation between source and sink
where TemplateInjectionFlow::flowPath(maliciousInputSource, templateInjectionSink)
// Generate vulnerability report with attack path details
select 
  templateInjectionSink.getNode(), 
  maliciousInputSource, 
  templateInjectionSink, 
  "This template construction incorporates a $@.", 
  maliciousInputSource.getNode(), 
  "user-controlled input"
/**
 * @name Server Side Template Injection
 * @description Identifies security vulnerabilities where untrusted user input is directly incorporated into template rendering contexts, potentially enabling remote code execution or cross-site scripting attacks.
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
// Specialized security analysis for template injection vulnerabilities
import semmle.python.security.dataflow.TemplateInjectionQuery
// Path graph representation for data flow tracking
import TemplateInjectionFlow::PathGraph

// Define source and sink variables with descriptive names
from TemplateInjectionFlow::PathNode maliciousSource, TemplateInjectionFlow::PathNode unsafeTemplateSink
// Verify data flow path exists between source and sink
where TemplateInjectionFlow::flowPath(maliciousSource, unsafeTemplateSink)
// Generate vulnerability report with path details
select 
  unsafeTemplateSink.getNode(), 
  maliciousSource, 
  unsafeTemplateSink, 
  "This template construction incorporates a $@.", 
  maliciousSource.getNode(), 
  "user-controlled input"
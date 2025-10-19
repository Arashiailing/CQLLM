/**
 * @name Server Side Template Injection
 * @description Detects security vulnerabilities where untrusted user input is incorporated into template rendering, which could lead to remote code execution or cross-site scripting attacks.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @security-severity 9.3
 * @id py/template-injection
 * @tags security
 *       external/cwe/cwe-074
 */

// Fundamental Python language support
import python
// Security analysis for template injection vulnerabilities
import semmle.python.security.dataflow.TemplateInjectionQuery
// Graph representation for data flow paths
import TemplateInjectionFlow::PathGraph

// Identify tainted data sources and vulnerable template sinks
from TemplateInjectionFlow::PathNode taintedDataSource, TemplateInjectionFlow::PathNode vulnerableTemplateSink
// Ensure there is a data flow path from the source to the sink
where TemplateInjectionFlow::flowPath(taintedDataSource, vulnerableTemplateSink)
// Generate a vulnerability report including the flow details
select 
  vulnerableTemplateSink.getNode(), 
  taintedDataSource, 
  vulnerableTemplateSink, 
  "This template construction incorporates a $@.", 
  taintedDataSource.getNode(), 
  "user-controlled input"
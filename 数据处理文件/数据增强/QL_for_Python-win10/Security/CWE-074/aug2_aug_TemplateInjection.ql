/**
 * @name Server Side Template Injection
 * @description Detects vulnerabilities where user-controlled input is incorporated into template construction, potentially leading to remote code execution or cross-site scripting attacks.
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

// Identify tainted source and vulnerable sink nodes
from TemplateInjectionFlow::PathNode taintedSource, TemplateInjectionFlow::PathNode vulnerableSink
// Verify data flow path exists between source and sink
where TemplateInjectionFlow::flowPath(taintedSource, vulnerableSink)
// Report vulnerability with flow details
select 
  vulnerableSink.getNode(), 
  taintedSource, 
  vulnerableSink, 
  "This template construction incorporates a $@.", 
  taintedSource.getNode(), 
  "user-controlled input"
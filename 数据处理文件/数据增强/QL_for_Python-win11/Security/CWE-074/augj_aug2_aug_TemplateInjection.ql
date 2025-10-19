/**
 * @name Server Side Template Injection
 * @description Identifies security flaws where untrusted user input is used in template rendering,
 *              potentially enabling remote code execution or cross-site scripting attacks.
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

// Find tainted data sources and vulnerable template sinks
from 
  TemplateInjectionFlow::PathNode sourceNode, 
  TemplateInjectionFlow::PathNode sinkNode
// Verify complete data flow path exists between source and sink
where 
  TemplateInjectionFlow::flowPath(sourceNode, sinkNode)
// Generate security alert with full flow visualization
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "This template rendering incorporates a $@.", 
  sourceNode.getNode(), 
  "user-controlled input"
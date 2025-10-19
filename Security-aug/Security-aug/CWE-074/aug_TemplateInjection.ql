/**
 * @name Server Side Template Injection
 * @description Incorporating user-controlled input into template construction may result in remote code execution or cross-site scripting vulnerabilities.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @security-severity 9.3
 * @id py/template-injection
 * @tags security
 *       external/cwe/cwe-074
 */

// Python language module import
import python
// Template injection analysis module import
import semmle.python.security.dataflow.TemplateInjectionQuery
// Path graph representation for data flow
import TemplateInjectionFlow::PathGraph

// Identify source and sink nodes in the data flow
from TemplateInjectionFlow::PathNode sourceNode, TemplateInjectionFlow::PathNode sinkNode
// Condition requiring data flow path existence between nodes
where TemplateInjectionFlow::flowPath(sourceNode, sinkNode)
// Output results with vulnerability details
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "This template construction depends on a $@.", 
  sourceNode.getNode(), 
  "user-provided value"
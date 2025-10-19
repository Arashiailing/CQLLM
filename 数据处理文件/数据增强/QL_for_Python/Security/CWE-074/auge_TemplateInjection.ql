/**
 * @name Server Side Template Injection
 * @description Detects when user-controlled input is used to construct templates,
 *              which can lead to remote code execution or cross-site scripting attacks.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @security-severity 9.3
 * @id py/template-injection
 * @tags security
 *       external/cwe/cwe-074
 */

// Import the Python language library for code analysis
import python
// Import the template injection security analysis module
import semmle.python.security.dataflow.TemplateInjectionQuery
// Import path graph representation for data flow visualization
import TemplateInjectionFlow::PathGraph

// Identify potential template injection vulnerabilities by tracking data flow
from TemplateInjectionFlow::PathNode taintedSource, TemplateInjectionFlow::PathNode vulnerableSink
// Check if there's a data flow path from the tainted source (user input) to the vulnerable sink (template construction)
where TemplateInjectionFlow::flowPath(taintedSource, vulnerableSink)
// Report the vulnerability with details about the source and sink
select vulnerableSink.getNode(), taintedSource, vulnerableSink, "This template construction depends on a $@.",
  taintedSource.getNode(), "user-provided value"
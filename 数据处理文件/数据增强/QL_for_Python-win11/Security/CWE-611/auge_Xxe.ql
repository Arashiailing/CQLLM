/**
 * @name XML external entity expansion
 * @description Detects when user-controlled input is parsed as XML without
 *              proper protection against XXE (XML External Entity) attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-827
 */

// Import necessary Python libraries for code analysis
import python

// Import XXE-specific security analysis modules
import semmle.python.security.dataflow.XxeQuery

// Import path graph representation for data flow visualization
import XxeFlow::PathGraph

// Define source and sink nodes for XXE vulnerability detection
from XxeFlow::PathNode userInput, XxeFlow::PathNode xmlParser

// Check if there's a data flow path from user input to XML parsing operation
where XxeFlow::flowPath(userInput, xmlParser)

// Generate alert with sink, source, and detailed message
select xmlParser.getNode(), userInput, xmlParser,
  "XML parsing depends on a $@ without proper protection against external entity expansion.",
  userInput.getNode(), "user-provided input"
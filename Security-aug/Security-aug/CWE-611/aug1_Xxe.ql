/**
 * @name XML external entity expansion vulnerability
 * @description Detects when user-controlled input is parsed as XML
 *              without proper protection against external entity expansion.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-827
 */

// Import necessary Python analysis libraries
import python

// Import XXE-specific security analysis modules
import semmle.python.security.dataflow.XxeQuery

// Import path graph representation for data flow tracking
import XxeFlow::PathGraph

// Identify vulnerable XML parsing flows from user input to XML processing
from XxeFlow::PathNode userInput, XxeFlow::PathNode xmlProcessing
where XxeFlow::flowPath(userInput, xmlProcessing)

// Report the vulnerable XML parsing without XXE protection
select xmlProcessing.getNode(), userInput, xmlProcessing,
  "XML parsing depends on a $@ without proper protection against external entity expansion.",
  userInput.getNode(), "user-controlled input"
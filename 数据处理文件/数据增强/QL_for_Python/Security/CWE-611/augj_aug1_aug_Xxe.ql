/**
 * @name XML external entity expansion vulnerability
 * @description Identifies unsafe XML parsing configurations that allow external entity
 *              expansion when handling untrusted user input without security mitigations.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-827
 */

// Core Python analysis framework providing code parsing capabilities
import python

// Specialized libraries for XML external entity (XXE) vulnerability analysis
import semmle.python.security.dataflow.XxeQuery

// Utilities for constructing and analyzing data flow path graphs
import XxeFlow::PathGraph

// Detect insecure XML processing flows from untrusted input to vulnerable parsers
from XxeFlow::PathNode entryPointNode, XxeFlow::PathNode vulnerableParserNode
// Validate that data flows from user-controlled sources to insecure XML processing
where XxeFlow::flowPath(entryPointNode, vulnerableParserNode)

// Report security finding with complete data flow trajectory
select vulnerableParserNode.getNode(), entryPointNode, vulnerableParserNode,
  "XML document processed by $@ without external entity expansion protections.", // Alert: Unprotected XML processing
  entryPointNode.getNode(), "user-provided input" // Origin of the vulnerability and source identification
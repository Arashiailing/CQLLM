/**
 * @name Clear-text logging of sensitive information
 * @description Detects cases where sensitive data is logged without encryption,
 *              potentially exposing confidential information to unauthorized parties.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/clear-text-logging-sensitive-data
 * @tags security
 *       external/cwe/cwe-312
 *       external/cwe/cwe-359
 *       external/cwe/cwe-532
 */

// Core Python analysis framework
import python
// Data flow tracking capabilities
private import semmle.python.dataflow.new.DataFlow
// Path visualization components
import CleartextLoggingFlow::PathGraph
// Specialized cleartext logging detection
import semmle.python.security.dataflow.CleartextLoggingQuery

from
  CleartextLoggingFlow::PathNode dataOrigin, 
  CleartextLoggingFlow::PathNode loggingTarget, 
  string sensitivityLevel
where
  // Establish data flow path between sensitive source and logging destination
  CleartextLoggingFlow::flowPath(dataOrigin, loggingTarget)
  and
  // Determine data sensitivity classification from the source
  sensitivityLevel = dataOrigin.getNode().(Source).getClassification()
select 
  // Report vulnerable logging location with path trace and sensitivity details
  loggingTarget.getNode(), 
  dataOrigin, 
  loggingTarget, 
  "This expression logs $@ as clear text.", 
  dataOrigin.getNode(),
  "sensitive data (" + sensitivityLevel + ")"
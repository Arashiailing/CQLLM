/**
 * @name CWE-532: Insertion of Sensitive Information into Log File
 * @description The product writes sensitive information to a log file.
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

import python
private import semmle.python.dataflow.new.DataFlow
import CleartextLoggingFlow::PathGraph
import semmle.python.security.dataflow.CleartextLoggingQuery

from 
  CleartextLoggingFlow::PathNode source, 
  CleartextLoggingFlow::PathNode sink, 
  string classification
where 
  CleartextLoggingFlow::flowPath(source, sink) and
  classification = source.getNode().(Source).getClassification()
select 
  sink.getNode(), 
  source, 
  sink, 
  "This expression logs $@ as clear text.", 
  source.getNode(), 
  "sensitive data (" + classification + ")"
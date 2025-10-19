/**
 * @name CWE-532: Insertion of Sensitive Information into Log File
 * @description The product writes sensitive information to a log file.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/checks
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.security.dataflow.CleartextLoggingQuery
import CleartextLoggingFlow::PathGraph

from 
  CleartextLoggingFlow::PathNode source,
  CleartextLoggingFlow::PathNode sink
where 
  CleartextLoggingFlow::flowPath(source, sink)
select 
  sink.getNode(), 
  source, 
  sink, 
  "This expression logs $@ as clear text.", 
  source.getNode(),
  "sensitive data"
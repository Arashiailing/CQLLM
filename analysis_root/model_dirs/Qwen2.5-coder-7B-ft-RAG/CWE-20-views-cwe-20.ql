/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind problem
 * @problem.severity warning
 * @security-severity 8.8
 * @precision high
 * @id py/views-cwe-20
 * @tags test
 */

import python
import semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.dataflow.new.ExportFlows
import semmle.python.security.dataflow.SqlInjectionQuery
import semmle.python.security.dataflow.SqlInjectionFlow::PathGraph

from ExportFlows::ExportNode exportNode, string description
where
  exists(SqlInjectionFlow::PathNode src, SqlInjectionFlow::PathNode sink |
    sink = exportNode.(ExportFlow::export).getASink() and
    sink != src and
    SqlInjectionFlow::flowPath(src, sink)
  )
  and
  description = "untrusted data flows to exported function"
  or
  exists(
    TaintedData::TaintedSource taintedSource,
    ExportFlow::ExportNode taintedSourceExport,
    ExportFlow::ExportNode exportNodeExport
  |
    exportNodeExport = exportNode and
    exportNodeExport = taintedSourceExport.(ExportFlow::export).getASink() and
    taintedSource.flowPath(taintedSourceExport, exportNodeExport)
  )
  and
  description = "tainted data flows through exported function"
select exportNode.getNode(), description
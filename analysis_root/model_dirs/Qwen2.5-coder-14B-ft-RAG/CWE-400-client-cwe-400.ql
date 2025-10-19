/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @sub-severity medium
 * @precision high
 * @id py/client-cwe-400
 */

import python
import semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow
import semmle.python.filters.Tests

from DataFlow::Node source, DataFlow::Node sink, string resource
where
  (
    source instanceof Source + strictmember and
    sink = source.getAFlowSink() and
    (
      resource = "memory"
      or
      resource = "disk space"
      or
      resource = "processes"
    )
  )
  or
  (
    source instanceof ModuleConfig and
    sink = source.getAModuleConfigurationFlowSink() and
    (
      resource = "modules"
      or
      resource = "packages"
    )
  )
  and
  not source.getScope().getScope*() instanceof TestScope
select sink, "An uncontrolled " + resource + " allocation depends on a $@.", source,
  source.toString()
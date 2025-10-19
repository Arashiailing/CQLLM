/**
 * @name CWE CATEGORY: Data Processing Errors
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/serverdensity_device
 */

import python
import semmle.python.security.dataflow.ServerDensityDeviceQuery
import ServerDensityDeviceFlow::PathGraph

from ServerDensityDeviceFlow::PathNode source, ServerDensityDeviceFlow::PathNode sink
where ServerDensityDeviceFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Server density device name depends on a $@", source.getNode(), "user-provided value"
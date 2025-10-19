/**
 * @name CWE-444: Inconsistent Interpretation of HTTP Requests ('HTTP Request/Response Smuggling')
 * @description nan
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @id py/receiver
 * @tags external/cwe/cwe-444
 *       external/cwe/cwe-730
 */

import python
import semmle.python.security.dataflow.ReceiverSmugglingQuery
import ReceiverSmugglingFlow::PathGraph
from ReceiverSmugglingFlow::PathNode source, ReceiverSmugglingFlow::PathNode sink
where ReceiverSmugglingFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Request smuggling vulnerability due to $@", source.getNode(),
  "untrusted request content"
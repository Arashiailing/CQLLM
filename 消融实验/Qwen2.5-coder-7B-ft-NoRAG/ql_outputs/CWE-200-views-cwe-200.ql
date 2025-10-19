/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description Exposure of sensitive information to an unauthorized actor
 * @id py/views-cwe-200
 */

import python
import semmle.python.security.dataflow.SensitiveDataExposureQuery

from DataFlow::PathNode source, DataFlow::PathNode sink
where SensitiveDataExposureQuery::flowPath(source, sink)
select sink.getNode(), source, sink, "Sensitive information exposed to an unauthorized actor."
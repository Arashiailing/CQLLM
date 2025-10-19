/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description nan
 * @id py/jwa
 */

import python
import semmle.python.security.dataflow.SensitiveDataExposureQuery
import SensitiveDataExposureFlow::PathGraph

from SensitiveDataExposureFlow::PathNode source, SensitiveDataExposureFlow::PathNode sink
where SensitiveDataExposureFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Sensitive information is exposed to an unauthorized actor."
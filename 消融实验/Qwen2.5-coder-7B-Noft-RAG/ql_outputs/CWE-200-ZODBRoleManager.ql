/**
* @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
*
@id py/ZODBRoleManager
*/
import python
import semmle.python.security.dataflow.SensitiveInformationExposureQuery predicate hasSensitiveDataFlow(PathNode source, PathNode sink) { exists(DataFlow::flowPath(source, sink)) }
from SensitiveInformationExposureFlow::PathNode source, SensitiveInformationExposureFlow::PathNode sink
    where hasSensitiveDataFlow(source, sink)
    select sink.getNode(), source, sink, "Sensitive information is exposed to an unauthorized actor."
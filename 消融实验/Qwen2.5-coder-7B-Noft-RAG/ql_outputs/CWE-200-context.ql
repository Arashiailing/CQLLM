/**
* @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
*
@id py/context
*/
import python
import semmle.python.security.dataflow.ExposureQuery predicate hasSensitiveDataExposure(DataFlow::Node node, string alert) { exists(DataFlow::Call call | call = node.getACall()
    and call.getFunc().pointsTo(ClassValue::sensitiveData())
    and call.getArgs()[0] = node) }
from DataFlow::PathNode source, DataFlow::PathNode sink
    where hasSensitiveDataExposure(source, "Sensitive data exposure")
    and ExposureFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Sensitive information exposed to an unauthorized actor."
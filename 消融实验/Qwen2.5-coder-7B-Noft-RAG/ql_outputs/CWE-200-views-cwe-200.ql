/**
* @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
*
@id py/views-cwe-200
*/
import python
import semmle.python.security.dataflow.StackTraceExposureQuery
from Call call, Value sensitiveData, Value exposedValue
    where StackTraceExposureQuery::exposesSensitiveInfo(call, sensitiveData, exposedValue)
    select call, "Potential exposure of sensitive information through an exception."
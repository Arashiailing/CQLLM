/**
* @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
*
@description Exposing sensitive information to an unauthorized act
    or through logging queries can lead to information leakage.
*
@id py/formats
*/
import python
import semmle.python.security.dataflow.LoggingQueryExposureQuery
import LoggingQueryExposureFlow::PathGraph
from LoggingQueryExposureFlow::PathNode source, LoggingQueryExposureFlow::PathNode sink
    where LoggingQueryExposureFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Sensitive information exposed in log query.", source.getNode(), "sensitive data"
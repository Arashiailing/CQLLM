/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description Exposing sensitive information to an unauthorized actor can lead to serious security vulnerabilities.
 * @id py/keycloak_cli
 */

import python
import semmle.python.security.dataflow.SensitiveInformationExposureQuery

from DataFlow::PathNode source, DataFlow::PathNode sink
where SensitiveInformationExposureQuery::flowPath(source, sink)
select sink.getNode(), source, sink, "Sensitive information is exposed to an unauthorized actor."
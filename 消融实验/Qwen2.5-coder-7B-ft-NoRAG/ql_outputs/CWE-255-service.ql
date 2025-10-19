/**
 * @name CWE-255: Exposure of credentials via insecure transport
 * @description Exposing credentials through insecure communication channels can lead to unauthorized access.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/service
 */

import python
import semmle.python.security.dataflow.CredentialsExposureQuery

from CredentialsFlow::PathNode source, CredentialsFlow::PathNode sink
where CredentialsFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Credentials are exposed through an insecure channel."
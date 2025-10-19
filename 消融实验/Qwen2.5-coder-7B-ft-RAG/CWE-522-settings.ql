/**
 * @name CWE-522: Insufficiently Protected Credentials
 * @description Storing credentials in plaintext is insecure because it exposes them to attackers who can steal them.
 * @kind problem
 * @problem.severity warning
 * @security-severity 8.1
 * @precision medium
 * @id py/insufficiently-protected-credentials
 * @tags security
 *       external/cwe/cwe-522
 */

import python
import semmle.python.security.dataflow.InsufficientlyProtectedCredentialsQuery
import InsufficientlyProtectedCredentialsFlow::PathGraph

from InsufficientlyProtectedCredentialsFlow::PathNode source, InsufficientlyProtectedCredentialsFlow::PathNode sink
where InsufficientlyProtectedCredentialsFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Credential storage location depends on a $@.", source.getNode(),
  "user-supplied value"
/**
 * @name CWE-522: Insufficiently Protected Credentials
 * @description Storing credentials in plain text can lead to unauthorized access.
 * @kind problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/manage
 */

import python
import semmle.python.security.dataflow.CredentialStorageQuery
import CredentialStorageFlow::PathGraph

from CredentialStorageFlow::PathNode source, CredentialStorageFlow::PathNode sink
where CredentialStorageFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Credentials are stored in plain text.", source.getNode(), "plaintext storage"
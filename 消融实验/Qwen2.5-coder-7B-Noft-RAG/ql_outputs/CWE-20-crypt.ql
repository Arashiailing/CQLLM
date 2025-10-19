/**
* @name CWE-20: Improper Input Validation
*
@id py/crypt
*/
import python
import semmle.python.security.dataflow.InsecureCryptographicPrimitivesQuery predicate uses_insecure_cryptography(Node node) { exists(CryptographicPrimitive crypto, PathNode source | crypto.getCalls().contains(node)
    and source.getNode() = node
    and not crypto.isSecure() ) }
from Node node
    where uses_insecure_cryptography(node)
    select node, "Insecure cryptographic primitive detected."
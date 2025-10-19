/**
* @name CWE-347: Improper Verification of Cryptographic Signature
*
@description The product does not verify,
    or incorrectly verifies, the cryptographic signature f
    or data.
*
@id py/sigver
*/
import python
import experimental.semmle.python.Concepts
from JwtDecoding jwtDecoding
    where not jwtDecoding.verifiesSignature()
    select jwtDecoding.getPayload(), "The cryptographic signature f
    or the data is not verified."
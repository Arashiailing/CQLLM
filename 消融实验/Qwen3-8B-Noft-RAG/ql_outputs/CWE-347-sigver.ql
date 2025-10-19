import python
import experimental.semmle.python.Concepts

from JwtDecoding jwtDecoding
where not jwtDecoding.verifiesSignature()
select jwtDecoding, "Cryptographic signature verification is missing"
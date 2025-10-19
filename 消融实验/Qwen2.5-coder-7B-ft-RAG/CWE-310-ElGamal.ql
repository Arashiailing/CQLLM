/**
 * @name CWE-310: Weak Sensitive Data Hashing
 * @description Detects usage of MD5, SHA-1, or other insecure hashing algorithms for sensitive data.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @id py/weak-sensitive-data-hashing
 * @tags security
 *       external/cwe/cwe-310
 */

import python
import experimental.cryptography.Concepts
import ElGamal

from ElGamal elgamal
where elgamal.hasPublicKey()
select elgamal,
  "Usage of $@ for public-key cryptography.", elgamal,
  "ElGamal"
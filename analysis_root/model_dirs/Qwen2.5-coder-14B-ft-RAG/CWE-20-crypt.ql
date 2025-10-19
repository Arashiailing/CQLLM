/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision medium
 * @id py/crypt
 * @tags correctness
 *       security
 *       external/cwe/cwe-20
 */

import python
import semmle.python.Concepts

from Cryptography::CryptographicAlgorithm cryptoAlg, string modeName
where
  // Check if encryption algorithm is used in unsafe mode
  (
    modeName = "ECB" and cryptoAlg.isInsecureMode(modeName)
  )
  or
  // Check if hashing algorithm is used without salt
  (
    modeName = "unsalted" and
    exists(Cryptography::HashAlgorithm hashAlg |
      hashAlg = cryptoAlg and
      not hashAlg.hasSalt()
    )
  )
select cryptoAlg,
  "$@ is used in a mode that is susceptible to cryptographic attacks.",
  cryptoAlg.getInitialization(),
  cryptoAlg.getName(),
  modeName,
  modeName + " mode"
/**
 * @name Detection of vulnerable cryptographic algorithms
 * @description Identifies the use of broken or weak cryptographic algorithms which may lead to security vulnerabilities.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @id py/weak-cryptographic-algorithm
 * @tags security
 *       external/cwe/cwe-327
 */

import python
import semmle.python.Concepts

// Find cryptographic operations that utilize weak encryption algorithms or insecure block modes
from Cryptography::CryptographicOperation encryptionOperation, string securityWarning
where
  // Determine if the encryption operation employs a weak cryptographic algorithm
  exists(Cryptography::EncryptionAlgorithm vulnerableAlgorithm | vulnerableAlgorithm = encryptionOperation.getAlgorithm() |
    vulnerableAlgorithm.isWeak() and
    securityWarning = "The cryptographic algorithm " + vulnerableAlgorithm.getName()
  )
  // Or check if the encryption operation uses a weak block cipher mode
  or
  encryptionOperation.getBlockMode().isWeak() and securityWarning = "The block mode " + encryptionOperation.getBlockMode()
select encryptionOperation, "$@ is broken or weak, and should not be used.", encryptionOperation.getInitialization(),
  securityWarning
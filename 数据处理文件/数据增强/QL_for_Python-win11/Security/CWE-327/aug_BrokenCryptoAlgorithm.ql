/**
 * @name Use of a broken or weak cryptographic algorithm
 * @description Using broken or weak cryptographic algorithms can compromise security.
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

// Identify cryptographic operations that use weak algorithms or block modes
from Cryptography::CryptographicOperation cryptoOperation, string warningMessagePrefix
where
  // Check if the cryptographic operation uses a weak encryption algorithm
  exists(Cryptography::EncryptionAlgorithm weakAlgorithm | weakAlgorithm = cryptoOperation.getAlgorithm() |
    weakAlgorithm.isWeak() and
    warningMessagePrefix = "The cryptographic algorithm " + weakAlgorithm.getName()
  )
  // Alternatively, check if the cryptographic operation uses a weak block mode
  or
  cryptoOperation.getBlockMode().isWeak() and warningMessagePrefix = "The block mode " + cryptoOperation.getBlockMode()
select cryptoOperation, "$@ is broken or weak, and should not be used.", cryptoOperation.getInitialization(),
  warningMessagePrefix
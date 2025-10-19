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

// Detect cryptographic operations that employ vulnerable algorithms or insecure block modes
from Cryptography::CryptographicOperation encOperation, string alertPrefix
where
  // Check for weak encryption algorithms
  exists(Cryptography::EncryptionAlgorithm insecureAlgorithm | insecureAlgorithm = encOperation.getAlgorithm() |
    insecureAlgorithm.isWeak() and
    alertPrefix = "The cryptographic algorithm " + insecureAlgorithm.getName()
  )
  // Check for weak block modes
  or
  encOperation.getBlockMode().isWeak() and 
  alertPrefix = "The block mode " + encOperation.getBlockMode()
select encOperation, "$@ is broken or weak, and should not be used.", encOperation.getInitialization(), alertPrefix
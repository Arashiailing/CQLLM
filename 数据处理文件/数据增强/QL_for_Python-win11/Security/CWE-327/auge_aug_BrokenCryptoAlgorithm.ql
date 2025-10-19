/**
 * @name Use of a broken or weak cryptographic algorithm
 * @description Employing broken or weak cryptographic algorithms can lead to security vulnerabilities.
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

// Locate cryptographic operations that utilize weak algorithms or block modes
from Cryptography::CryptographicOperation secureOp, string alertPrefix
where
  (
    // Check for weak encryption algorithm
    exists(Cryptography::EncryptionAlgorithm weakAlgo | 
      weakAlgo = secureOp.getAlgorithm() and
      weakAlgo.isWeak() and
      alertPrefix = "The cryptographic algorithm " + weakAlgo.getName()
    )
    // Check for weak block mode
    or
    secureOp.getBlockMode().isWeak() and 
    alertPrefix = "The block mode " + secureOp.getBlockMode()
  )
select secureOp, "$@ is broken or weak, and should not be used.", secureOp.getInitialization(),
  alertPrefix
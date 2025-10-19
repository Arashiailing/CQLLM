/**
 * @name Use of a broken or weak cryptographic algorithm
 * @description Employing broken or weak cryptographic algorithms or block modes can lead to security vulnerabilities.
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

// Identify cryptographic operations using vulnerable algorithms or insecure block modes
from Cryptography::CryptographicOperation cryptoOperation, string issueDescription
where
  (
    // Detect usage of weak encryption algorithms
    exists(Cryptography::EncryptionAlgorithm vulnerableAlgorithm | 
      vulnerableAlgorithm = cryptoOperation.getAlgorithm() and
      vulnerableAlgorithm.isWeak() and
      issueDescription = "The cryptographic algorithm " + vulnerableAlgorithm.getName()
    )
    // Detect usage of weak block modes
    or
    exists(Cryptography::BlockMode insecureMode | 
      insecureMode = cryptoOperation.getBlockMode() and
      insecureMode.isWeak() and
      issueDescription = "The block mode " + insecureMode
    )
  )
select cryptoOperation, "$@ is broken or weak, and should not be used.", cryptoOperation.getInitialization(),
  issueDescription
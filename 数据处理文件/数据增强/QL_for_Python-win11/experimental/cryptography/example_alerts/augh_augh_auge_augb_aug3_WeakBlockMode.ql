/**
 * @name Weak block mode
 * @description Detects symmetric encryption operations employing block modes 
 *              that are considered weak, deprecated, or inappropriate for secure implementations.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Select cryptographic operations and their corresponding security alert messages
from CryptographicArtifact cryptoOperation, string securityAlert
where
  // Exclude false positives from cryptography/hazmat paths
  // Note: ECB mode is acceptable when used internally within keywrap operations
  not cryptoOperation.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Case 1: Analyze BlockMode instances for security vulnerabilities
    cryptoOperation instanceof BlockMode and
    // ECB mode is only allowed within KeyWrapOperation contexts
    (cryptoOperation.(BlockMode).getBlockModeName() = "ECB" implies 
     not cryptoOperation instanceof KeyWrapOperation) and
    exists(string encryptionMode | 
      encryptionMode = cryptoOperation.(BlockMode).getBlockModeName() and
      // Only CBC, CTS, and XTS modes are approved for general use
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not encryptionMode = ["CBC", "CTS", "XTS"] and
      // Generate appropriate security alert based on the detected block mode
      (
        encryptionMode = unknownAlgorithm() and
        securityAlert = "Use of unrecognized block mode algorithm."
        or
        encryptionMode in ["GCM", "CCM"] and
        securityAlert =
          "Use of block mode algorithm " + encryptionMode +
            " requires special crypto board approval/review."
        or
        securityAlert = "Use of unapproved block mode algorithm or API " + encryptionMode + "."
      )
    )
    or
    // Case 2: Detect SymmetricCipher instances without explicit block mode specification
    cryptoOperation instanceof SymmetricCipher and
    not cryptoOperation.(SymmetricCipher).hasBlockMode() and
    securityAlert = "Cipher has unspecified block mode algorithm."
  )
select cryptoOperation, securityAlert
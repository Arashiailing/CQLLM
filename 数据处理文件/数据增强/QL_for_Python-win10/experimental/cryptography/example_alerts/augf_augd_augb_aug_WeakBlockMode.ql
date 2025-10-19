/**
 * @name Weak block mode detection
 * @description Detects symmetric encryption operations that employ weak, deprecated, or unauthorized block cipher modes.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Analyze cryptographic elements to identify potential security vulnerabilities
from CryptographicArtifact cryptoElement, string securityAlert
where
  // Filter out false positives from cryptography/hazmat module paths
  // This is particularly important for ECB mode usage in key wrapping operations
  not cryptoElement.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Process block cipher mode operations
    cryptoElement instanceof BlockMode and
    exists(string blockCipherMode | blockCipherMode = cryptoElement.(BlockMode).getBlockModeName() |
      // ECB mode is only acceptable for key wrapping operations
      (blockCipherMode = "ECB" implies not cryptoElement instanceof KeyWrapOperation) and
      // Only CBC, CTS, and XTS modes are considered approved
      // Based on Microsoft Security Cryptography Requirements 10002
      not blockCipherMode = ["CBC", "CTS", "XTS"] and
      // Generate appropriate security alert based on the detected mode
      if blockCipherMode = unknownAlgorithm()
      then securityAlert = "Use of unrecognized block mode algorithm."
      else
        if blockCipherMode in ["GCM", "CCM"]
        then
          securityAlert =
            "Use of block mode algorithm " + blockCipherMode +
              " requires special crypto board approval/review."
        else securityAlert = "Use of unapproved block mode algorithm or API " + blockCipherMode + "."
    )
    or
    // Identify symmetric ciphers that lack a specified block mode
    cryptoElement instanceof SymmetricCipher and
    not cryptoElement.(SymmetricCipher).hasBlockMode() and
    securityAlert = "Cipher has unspecified block mode algorithm."
  )
select cryptoElement, securityAlert
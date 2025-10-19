/**
 * @name Weak block mode
 * @description Detects symmetric encryption block modes that are identified as weak, outdated, or non-compliant with established security standards.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Select encryption operations and generate appropriate security alerts
from CryptographicArtifact encryptionOperation, string securityAlert
where
  // Filter out false positives from cryptography/hazmat paths
  // This is particularly important for cases where ECB is used internally in keywrap operations
  not encryptionOperation.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Analyze BlockMode instances for potentially weak configurations
    encryptionOperation instanceof BlockMode and
    // ECB mode is restricted to KeyWrapOperations only
    (encryptionOperation.(BlockMode).getBlockModeName() = "ECB" implies not encryptionOperation instanceof KeyWrapOperation) and
    exists(string blockCipherMode | blockCipherMode = encryptionOperation.(BlockMode).getBlockModeName() |
      // Only CBC, CTS, and XTS modes are approved per security guidelines
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not blockCipherMode = ["CBC", "CTS", "XTS"] and
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
    // Identify SymmetricCipher instances that lack a specified block mode
    encryptionOperation instanceof SymmetricCipher and
    not encryptionOperation.(SymmetricCipher).hasBlockMode() and
    securityAlert = "Cipher has unspecified block mode algorithm."
  )
select encryptionOperation, securityAlert
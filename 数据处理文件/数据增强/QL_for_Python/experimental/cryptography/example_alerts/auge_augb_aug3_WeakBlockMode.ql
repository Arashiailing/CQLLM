/**
 * @name Weak block mode
 * @description Detects symmetric encryption using block modes that are considered weak, 
 *              deprecated, or not approved for use in secure applications.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Select encryption artifacts and their corresponding security alerts
from CryptographicArtifact encryptionArtifact, string securityAlert
where
  // Exclude false positives from cryptography/hazmat paths
  // Important: ECB mode is acceptable when used internally in keywrap operations
  not encryptionArtifact.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Check for BlockMode instances with security concerns
    encryptionArtifact instanceof BlockMode and
    // ECB mode is only permitted within KeyWrapOperation contexts
    (encryptionArtifact.(BlockMode).getBlockModeName() = "ECB" implies 
     not encryptionArtifact instanceof KeyWrapOperation) and
    exists(string modeName | 
      modeName = encryptionArtifact.(BlockMode).getBlockModeName() and
      // Only CBC, CTS, and XTS modes are approved for general use
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not modeName = ["CBC", "CTS", "XTS"] and
      // Generate appropriate security alert based on the detected block mode
      (
        modeName = unknownAlgorithm() and
        securityAlert = "Use of unrecognized block mode algorithm."
        or
        modeName in ["GCM", "CCM"] and
        securityAlert =
          "Use of block mode algorithm " + modeName +
            " requires special crypto board approval/review."
        or
        securityAlert = "Use of unapproved block mode algorithm or API " + modeName + "."
      )
    )
    or
    // Check for SymmetricCipher instances lacking an explicit block mode specification
    encryptionArtifact instanceof SymmetricCipher and
    not encryptionArtifact.(SymmetricCipher).hasBlockMode() and
    securityAlert = "Cipher has unspecified block mode algorithm."
  )
select encryptionArtifact, securityAlert
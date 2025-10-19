/**
 * @name Weak block mode
 * @description Identifies symmetric encryption block modes that are considered weak, deprecated, or non-compliant with security standards.
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
  // This specifically addresses cases where ECB is used internally within keywrap operations
  not exists(string artifactPath |
    artifactPath = encryptionArtifact.asExpr()
        .getLocation()
        .getFile()
        .getAbsolutePath()
        .toString() and
    artifactPath.matches("%cryptography/hazmat/%")
  ) and
  (
    // Case 1: BlockMode instances with potentially weak configurations
    encryptionArtifact instanceof BlockMode and
    // ECB mode is only permitted for KeyWrapOperations
    (encryptionArtifact.(BlockMode).getBlockModeName() = "ECB" implies not encryptionArtifact instanceof KeyWrapOperation) and
    // Check if the block mode is weak or unapproved
    exists(string modeName | 
      modeName = encryptionArtifact.(BlockMode).getBlockModeName() and
      // Only allow CBC, CTS, and XTS modes as per security requirements
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not modeName = ["CBC", "CTS", "XTS"] and
      // Generate appropriate security alert based on the block mode
      (
        modeName = unknownAlgorithm() and
        securityAlert = "Use of unrecognized block mode algorithm."
        or
        modeName in ["GCM", "CCM"] and
        securityAlert = "Use of block mode algorithm " + modeName + " requires special crypto board approval/review."
        or
        securityAlert = "Use of unapproved block mode algorithm or API " + modeName + "."
      )
    )
    or
    // Case 2: SymmetricCipher instances without a specified block mode
    encryptionArtifact instanceof SymmetricCipher and
    not encryptionArtifact.(SymmetricCipher).hasBlockMode() and
    securityAlert = "Cipher has unspecified block mode algorithm."
  )
select encryptionArtifact, securityAlert
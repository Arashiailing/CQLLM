/**
 * @name Weak block mode
 * @description Detects symmetric encryption block modes that are weak, outdated, or not approved for use.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Identify cryptographic artifacts and generate corresponding security warnings
from CryptographicArtifact encryptionElement, string securityAlert
where
  // Exclude false positives from cryptography/hazmat paths
  // This is important because ECB mode is used internally in keywrap operations
  not encryptionElement.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Case 1: Identify BlockMode instances with security vulnerabilities
    encryptionElement instanceof BlockMode and
    // ECB mode is permitted only for KeyWrapOperations
    (encryptionElement.(BlockMode).getBlockModeName() = "ECB" implies 
     not encryptionElement instanceof KeyWrapOperation) and
    exists(string modeName | 
      modeName = encryptionElement.(BlockMode).getBlockModeName() and
      // Only CBC, CTS, and XTS modes are considered secure
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not modeName = ["CBC", "CTS", "XTS"] and
      // Generate appropriate security alert based on the block mode
      (
        modeName = unknownAlgorithm() and
        securityAlert = "Detected use of unrecognized block mode algorithm."
        or
        modeName in ["GCM", "CCM"] and
        securityAlert =
          "Block mode algorithm " + modeName +
            " requires special crypto board approval/review."
        or
        securityAlert = "Unapproved block mode algorithm or API detected: " + modeName + "."
      )
    )
    or
    // Case 2: Identify SymmetricCipher instances without a specified block mode
    encryptionElement instanceof SymmetricCipher and
    not encryptionElement.(SymmetricCipher).hasBlockMode() and
    securityAlert = "Detected cipher with unspecified block mode algorithm."
  )
select encryptionElement, securityAlert
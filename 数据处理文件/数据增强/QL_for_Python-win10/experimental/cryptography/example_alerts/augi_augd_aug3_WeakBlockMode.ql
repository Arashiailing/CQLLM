/**
 * @name Weak block mode
 * @description Identifies symmetric encryption block modes that are considered weak, obsolete, or otherwise unapproved.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Select cryptographic artifacts and their corresponding warning messages
from CryptographicArtifact cryptoArtifact, string warningMessage
where
  // Exclude false positives from cryptography/hazmat paths
  // This is important because ECB mode is used internally in keywrap operations
  not cryptoArtifact.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Check for BlockMode instances
    cryptoArtifact instanceof BlockMode and
    // Handle ECB mode exception: only allowed for KeyWrapOperations
    (cryptoArtifact.(BlockMode).getBlockModeName() = "ECB" implies 
     not cryptoArtifact instanceof KeyWrapOperation) and
    // Determine the block mode name and check if it's approved
    exists(string modeName | modeName = cryptoArtifact.(BlockMode).getBlockModeName() |
      // Only CBC, CTS, and XTS modes are approved
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not modeName = ["CBC", "CTS", "XTS"] and
      // Generate appropriate warning message based on the block mode
      (
        modeName = unknownAlgorithm() and
        warningMessage = "Use of unrecognized block mode algorithm."
        or
        modeName in ["GCM", "CCM"] and
        warningMessage = "Use of block mode algorithm " + modeName + " requires special crypto board approval/review."
        or
        warningMessage = "Use of unapproved block mode algorithm or API " + modeName + "."
      )
    )
    or
    // Check for SymmetricCipher instances without a specified block mode
    cryptoArtifact instanceof SymmetricCipher and
    not cryptoArtifact.(SymmetricCipher).hasBlockMode() and
    warningMessage = "Cipher has unspecified block mode algorithm."
  )
select cryptoArtifact, warningMessage
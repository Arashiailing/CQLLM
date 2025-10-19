/**
 * @name Weak block mode
 * @description Detects the use of symmetric encryption block modes that are considered weak, obsolete, or otherwise unapproved.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Select cryptographic artifacts and corresponding warning messages
from CryptographicArtifact cryptoArtifact, string warningMessage
where
  // Exclude false positives by filtering out results from cryptography/hazmat paths
  // This is particularly important for ECB mode used internally in keywrap operations
  not cryptoArtifact.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Case 1: Check for BlockMode instances
    cryptoArtifact instanceof BlockMode and
    // ECB mode is only allowed for KeyWrapOperations
    (cryptoArtifact.(BlockMode).getBlockModeName() = "ECB" implies 
     not cryptoArtifact instanceof KeyWrapOperation) and
    exists(string modeName | modeName = cryptoArtifact.(BlockMode).getBlockModeName() |
      // Only CBC, CTS, and XTS modes are approved
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not modeName = ["CBC", "CTS", "XTS"] and
      if modeName = unknownAlgorithm()
      then warningMessage = "Use of unrecognized block mode algorithm."
      else
        if modeName in ["GCM", "CCM"]
        then
          warningMessage =
            "Use of block mode algorithm " + modeName +
              " requires special crypto board approval/review."
        else warningMessage = "Use of unapproved block mode algorithm or API " + modeName + "."
    )
    or
    // Case 2: Check for SymmetricCipher instances without a specified block mode
    cryptoArtifact instanceof SymmetricCipher and
    not cryptoArtifact.(SymmetricCipher).hasBlockMode() and
    warningMessage = "Cipher has unspecified block mode algorithm."
  )
select cryptoArtifact, warningMessage
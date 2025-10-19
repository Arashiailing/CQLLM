/**
 * @name Weak block mode
 * @description Identifies symmetric encryption block modes that are classified as weak, outdated, or not approved for use.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Select encryption artifacts and their corresponding alert messages
from CryptographicArtifact encryptionArtifact, string alertMessage
where
  // Filter out false positives by excluding results from cryptography/hazmat paths
  // This is crucial because ECB mode is used internally in keywrap operations
  not encryptionArtifact.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Scenario 1: Examine BlockMode instances
    encryptionArtifact instanceof BlockMode and
    // ECB mode is permitted only for KeyWrapOperations
    (encryptionArtifact.(BlockMode).getBlockModeName() = "ECB" implies 
     not encryptionArtifact instanceof KeyWrapOperation) and
    exists(string blockModeName | blockModeName = encryptionArtifact.(BlockMode).getBlockModeName() |
      // Only CBC, CTS, and XTS modes are approved
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not blockModeName = ["CBC", "CTS", "XTS"] and
      // Generate appropriate alert message based on the block mode
      if blockModeName = unknownAlgorithm()
      then alertMessage = "Use of unrecognized block mode algorithm."
      else
        if blockModeName in ["GCM", "CCM"]
        then
          alertMessage =
            "Use of block mode algorithm " + blockModeName +
              " requires special crypto board approval/review."
        else alertMessage = "Use of unapproved block mode algorithm or API " + blockModeName + "."
    )
    or
    // Scenario 2: Examine SymmetricCipher instances without a specified block mode
    encryptionArtifact instanceof SymmetricCipher and
    not encryptionArtifact.(SymmetricCipher).hasBlockMode() and
    alertMessage = "Cipher has unspecified block mode algorithm."
  )
select encryptionArtifact, alertMessage
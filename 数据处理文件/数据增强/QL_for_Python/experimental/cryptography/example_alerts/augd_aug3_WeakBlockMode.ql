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

// Select cryptographic elements and their corresponding alert messages
from CryptographicArtifact cryptoElement, string alertMessage
where
  // Filter out false positives from cryptography/hazmat paths
  // This is crucial because ECB mode is used internally in keywrap operations
  not cryptoElement.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Check for BlockMode instances
    cryptoElement instanceof BlockMode and
    // Handle ECB mode exception: only allowed for KeyWrapOperations
    (cryptoElement.(BlockMode).getBlockModeName() = "ECB" implies 
     not cryptoElement instanceof KeyWrapOperation) and
    // Determine the block mode name and check if it's approved
    exists(string blockModeName | blockModeName = cryptoElement.(BlockMode).getBlockModeName() |
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
    // Check for SymmetricCipher instances without a specified block mode
    cryptoElement instanceof SymmetricCipher and
    not cryptoElement.(SymmetricCipher).hasBlockMode() and
    alertMessage = "Cipher has unspecified block mode algorithm."
  )
select cryptoElement, alertMessage
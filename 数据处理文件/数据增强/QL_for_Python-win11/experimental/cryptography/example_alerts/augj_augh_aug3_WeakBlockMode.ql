/**
 * @name Weak block mode
 * @description Detects symmetric encryption block modes that are classified as weak, deprecated, or unauthorized for use.
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
  // Exclude false positives by filtering out cryptography/hazmat paths
  // This prevents flagging ECB mode when used internally in keywrap operations
  not cryptoArtifact.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Analyze BlockMode implementations
    cryptoArtifact instanceof BlockMode and
    // ECB mode is only permitted within KeyWrapOperations
    (cryptoArtifact.(BlockMode).getBlockModeName() = "ECB" implies 
     not cryptoArtifact instanceof KeyWrapOperation) and
    exists(string blockModeName | blockModeName = cryptoArtifact.(BlockMode).getBlockModeName() |
      // Only CBC, CTS, and XTS modes are approved for general use
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not blockModeName = ["CBC", "CTS", "XTS"] and
      // Generate appropriate warning message based on the detected mode
      if blockModeName = unknownAlgorithm()
      then warningMessage = "Detected usage of an unrecognized block mode algorithm."
      else
        if blockModeName in ["GCM", "CCM"]
        then
          warningMessage =
            "Usage of block mode algorithm " + blockModeName +
              " requires special cryptographic board approval/review."
        else warningMessage = "Detected usage of unapproved block mode algorithm or API " + blockModeName + "."
    )
    or
    // Analyze SymmetricCipher implementations without a specified block mode
    cryptoArtifact instanceof SymmetricCipher and
    not cryptoArtifact.(SymmetricCipher).hasBlockMode() and
    warningMessage = "Cipher implementation has unspecified block mode algorithm."
  )
select cryptoArtifact, warningMessage
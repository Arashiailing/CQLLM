/**
 * @name Weak block mode
 * @description Identifies symmetric encryption operations that utilize block modes 
 *              classified as weak, deprecated, or not suitable for secure applications.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Select cryptographic artifacts and their corresponding security alert messages
from CryptographicArtifact cryptoArtifact, string alertMessage
where
  // Filter out false positives originating from cryptography/hazmat paths
  // Note: ECB mode is acceptable when used internally within keywrap operations
  not cryptoArtifact.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Case 1: Analyze BlockMode instances for security vulnerabilities
    cryptoArtifact instanceof BlockMode and
    // ECB mode is only allowed within KeyWrapOperation contexts
    (cryptoArtifact.(BlockMode).getBlockModeName() = "ECB" implies 
     not cryptoArtifact instanceof KeyWrapOperation) and
    exists(string blockModeName | 
      blockModeName = cryptoArtifact.(BlockMode).getBlockModeName() and
      // Only CBC, CTS, and XTS modes are approved for general use
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not blockModeName = ["CBC", "CTS", "XTS"] and
      // Generate appropriate security alert based on the detected block mode
      (
        blockModeName = unknownAlgorithm() and
        alertMessage = "Use of unrecognized block mode algorithm."
        or
        blockModeName in ["GCM", "CCM"] and
        alertMessage =
          "Use of block mode algorithm " + blockModeName +
            " requires special crypto board approval/review."
        or
        alertMessage = "Use of unapproved block mode algorithm or API " + blockModeName + "."
      )
    )
    or
    // Case 2: Detect SymmetricCipher instances without explicit block mode specification
    cryptoArtifact instanceof SymmetricCipher and
    not cryptoArtifact.(SymmetricCipher).hasBlockMode() and
    alertMessage = "Cipher has unspecified block mode algorithm."
  )
select cryptoArtifact, alertMessage
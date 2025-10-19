/**
 * @name Weak block mode
 * @description Identifies symmetric encryption operations using weak, obsolete, or unapproved block modes
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
  // Exclude false positives from cryptography/hazmat paths
  // (e.g., ECB usage inside keywrap operations)
  not cryptoArtifact.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Case 1: Check for weak block modes
    cryptoArtifact instanceof BlockMode and
    (
      // ECB mode is only permitted in KeyWrapOperations
      not (cryptoArtifact.(BlockMode).getBlockModeName() = "ECB" and 
           cryptoArtifact instanceof KeyWrapOperation) and
      // Generate warning message based on block mode type
      exists(string blockModeName | 
        blockModeName = cryptoArtifact.(BlockMode).getBlockModeName() |
        // Only CBC, CTS, and XTS modes are approved
        // Ref: Microsoft.Security.Cryptography.10002
        not blockModeName = ["CBC", "CTS", "XTS"] and
        (
          // Handle unrecognized block mode
          blockModeName = unknownAlgorithm() and
          warningMessage = "Use of unrecognized block mode algorithm."
          or
          // Handle modes requiring special approval
          blockModeName in ["GCM", "CCM"] and
          warningMessage = "Use of block mode algorithm " + blockModeName +
            " requires special crypto board approval/review."
          or
          // Handle all other unapproved modes
          not (blockModeName = unknownAlgorithm() or blockModeName in ["GCM", "CCM"]) and
          warningMessage = "Use of unapproved block mode algorithm or API " + blockModeName + "."
        )
      )
    )
    or
    // Case 2: Check for ciphers without specified block mode
    cryptoArtifact instanceof SymmetricCipher and
    not cryptoArtifact.(SymmetricCipher).hasBlockMode() and
    warningMessage = "Cipher has unspecified block mode algorithm."
  )
select cryptoArtifact, warningMessage
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

// Select encryption operations and corresponding warning messages
from CryptographicArtifact encryptionOperation, string warningMessage
where
  // Filter out false positives from cryptography/hazmat paths
  // (e.g., ECB usage inside keywrap operations)
  not encryptionOperation.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Case 1: Check for weak block modes
    encryptionOperation instanceof BlockMode and
    // ECB mode is only permitted in KeyWrapOperations
    (encryptionOperation.(BlockMode).getBlockModeName() = "ECB" implies 
      not encryptionOperation instanceof KeyWrapOperation) and
    exists(string blockModeName | blockModeName = encryptionOperation.(BlockMode).getBlockModeName() |
      // Only CBC, CTS, and XTS modes are approved
      // Ref: Microsoft.Security.Cryptography.10002
      not blockModeName = ["CBC", "CTS", "XTS"] and
      // Generate appropriate warning message based on the block mode
      if blockModeName = unknownAlgorithm()
      then warningMessage = "Use of unrecognized block mode algorithm."
      else
        if blockModeName in ["GCM", "CCM"]
        then
          warningMessage =
            "Use of block mode algorithm " + blockModeName +
              " requires special crypto board approval/review."
        else warningMessage = "Use of unapproved block mode algorithm or API " + blockModeName + "."
    )
    or
    // Case 2: Check for ciphers without specified block mode
    encryptionOperation instanceof SymmetricCipher and
    not encryptionOperation.(SymmetricCipher).hasBlockMode() and
    warningMessage = "Cipher has unspecified block mode algorithm."
  )
select encryptionOperation, warningMessage
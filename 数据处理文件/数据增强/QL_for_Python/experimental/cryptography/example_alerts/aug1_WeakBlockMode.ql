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

// Select cryptographic operations and corresponding alert messages
from CryptographicArtifact cryptoOperation, string alertMessage
where
  // Exclude false positives from cryptography/hazmat paths
  // (e.g., ECB usage inside keywrap operations)
  not cryptoOperation.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Check for weak block modes
    cryptoOperation instanceof BlockMode and
    // ECB mode only permitted in KeyWrapOperations
    (cryptoOperation.(BlockMode).getBlockModeName() = "ECB" implies 
      not cryptoOperation instanceof KeyWrapOperation) and
    exists(string modeName | modeName = cryptoOperation.(BlockMode).getBlockModeName() |
      // Only CBC, CTS, and XTS modes are approved
      // Ref: Microsoft.Security.Cryptography.10002
      not modeName = ["CBC", "CTS", "XTS"] and
      if modeName = unknownAlgorithm()
      then alertMessage = "Use of unrecognized block mode algorithm."
      else
        if modeName in ["GCM", "CCM"]
        then
          alertMessage =
            "Use of block mode algorithm " + modeName +
              " requires special crypto board approval/review."
        else alertMessage = "Use of unapproved block mode algorithm or API " + modeName + "."
    )
    or
    // Check for ciphers without specified block mode
    cryptoOperation instanceof SymmetricCipher and
    not cryptoOperation.(SymmetricCipher).hasBlockMode() and
    alertMessage = "Cipher has unspecified block mode algorithm."
  )
select cryptoOperation, alertMessage
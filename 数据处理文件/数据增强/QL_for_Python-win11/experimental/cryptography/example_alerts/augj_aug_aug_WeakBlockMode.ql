/**
 * @name Weak block mode
 * @description Identifies symmetric encryption operations that utilize weak, obsolete, or otherwise unapproved block modes.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Find cryptographic operations with weak block modes
from CryptographicArtifact cryptoOperation, string warningMessage
where
  // Exclude false positives from the cryptography/hazmat path
  not cryptoOperation.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Case 1: BlockMode instances with unapproved modes
    cryptoOperation instanceof BlockMode and
    // ECB mode is only allowed for KeyWrapOperations
    (cryptoOperation.(BlockMode).getBlockModeName() = "ECB" implies not cryptoOperation instanceof KeyWrapOperation) and
    exists(string modeName | modeName = cryptoOperation.(BlockMode).getBlockModeName() |
      // Only CBC, CTS, and XTS modes are approved
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not modeName = ["CBC", "CTS", "XTS"] and
      // Generate warning message based on the block mode type
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
    // Case 2: SymmetricCipher instances without a specified block mode algorithm
    cryptoOperation instanceof SymmetricCipher and
    not cryptoOperation.(SymmetricCipher).hasBlockMode() and
    warningMessage = "Cipher has unspecified block mode algorithm."
  )
select cryptoOperation, warningMessage
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

// Select cryptographic operations and generate appropriate alert messages
from CryptographicArtifact cryptoOperation, string alertMessage
where
  // Exclude false positives from projects that include the entire cryptography module
  // Filter out results matching the cryptography/hazmat path
  // Particularly important for ECB usage within keywrap operations
  not cryptoOperation.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Case 1: Check if the operation is a BlockMode instance
    cryptoOperation instanceof BlockMode and
    // ECB mode is only allowed for KeyWrapOperations, so alert if ECB is not part of a KeyWrapOperation
    (cryptoOperation.(BlockMode).getBlockModeName() = "ECB" implies not cryptoOperation instanceof KeyWrapOperation) and
    exists(string modeName | modeName = cryptoOperation.(BlockMode).getBlockModeName() |
      // Only CBC, CTS, and XTS modes are approved
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
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
    // Case 2: Check if the operation is a SymmetricCipher instance without a specified block mode algorithm
    cryptoOperation instanceof SymmetricCipher and
    not cryptoOperation.(SymmetricCipher).hasBlockMode() and
    alertMessage = "Cipher has unspecified block mode algorithm."
  )
select cryptoOperation, alertMessage
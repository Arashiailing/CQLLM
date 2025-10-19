/**
 * @name Weak block mode
 * @description Detects symmetric encryption operations that employ weak, deprecated, or non-compliant block cipher modes.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Identify cryptographic operations and generate corresponding security alert messages
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
    // Case 1: Operation is a BlockMode instance
    cryptoOperation instanceof BlockMode and
    // ECB mode is only allowed for KeyWrapOperations, so alert if ECB is not part of a KeyWrapOperation
    (cryptoOperation.(BlockMode).getBlockModeName() = "ECB" implies not cryptoOperation instanceof KeyWrapOperation) and
    exists(string modeName | modeName = cryptoOperation.(BlockMode).getBlockModeName() |
      // Only CBC, CTS, and XTS modes are approved
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not modeName = ["CBC", "CTS", "XTS"] and
      (
        // Handle unknown algorithm case
        if modeName = unknownAlgorithm()
        then alertMessage = "Use of unrecognized block mode algorithm."
        // Handle algorithms requiring special approval
        else if modeName in ["GCM", "CCM"]
        then
          alertMessage =
            "Use of block mode algorithm " + modeName +
              " requires special crypto board approval/review."
        // Handle all other unapproved algorithms
        else alertMessage = "Use of unapproved block mode algorithm or API " + modeName + "."
      )
    )
    or
    // Case 2: Operation is a SymmetricCipher instance without a specified block mode algorithm
    cryptoOperation instanceof SymmetricCipher and
    not cryptoOperation.(SymmetricCipher).hasBlockMode() and
    alertMessage = "Cipher has unspecified block mode algorithm."
  )
select cryptoOperation, alertMessage
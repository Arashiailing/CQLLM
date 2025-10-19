/**
 * @name Weak block mode
 * @description Detects symmetric encryption operations employing weak, outdated, or non-compliant block cipher modes.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Analyze cryptographic objects and generate corresponding security alerts
from CryptographicArtifact cryptoObj, string alertMessage
where
  // Exclude false positives from projects that include the entire cryptography module
  // Filter out results matching the cryptography/hazmat path
  // This is particularly important for ECB usage within keywrap operations
  not cryptoObj.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Scenario 1: The object represents a BlockMode instance
    cryptoObj instanceof BlockMode and
    // ECB mode is only permitted for KeyWrapOperations, so flag ECB when not part of a KeyWrapOperation
    (cryptoObj.(BlockMode).getBlockModeName() = "ECB" implies not cryptoObj instanceof KeyWrapOperation) and
    exists(string modeName | modeName = cryptoObj.(BlockMode).getBlockModeName() |
      // Only CBC, CTS, and XTS modes are approved
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not modeName = ["CBC", "CTS", "XTS"] and
      // Generate appropriate alert message based on the block mode type
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
    // Scenario 2: The object represents a SymmetricCipher instance without a specified block mode algorithm
    cryptoObj instanceof SymmetricCipher and
    not cryptoObj.(SymmetricCipher).hasBlockMode() and
    alertMessage = "Cipher has unspecified block mode algorithm."
  )
select cryptoObj, alertMessage
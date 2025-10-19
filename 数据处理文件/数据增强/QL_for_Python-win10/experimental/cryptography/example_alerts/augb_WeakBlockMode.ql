/**
 * @name Weak block mode
 * @description Identifies symmetric encryption block modes that are considered weak, deprecated, or non-compliant with security standards.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Select cryptographic operations and their corresponding alert messages
from CryptographicArtifact cryptoOperation, string alertMessage
where
  // Exclude false positives by filtering out any results from cryptography/hazmat paths
  // This specifically addresses cases where ECB is used internally within keywrap operations
  not cryptoOperation.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Check for BlockMode instances with potentially weak configurations
    cryptoOperation instanceof BlockMode and
    // ECB mode is only permitted for KeyWrapOperations
    (cryptoOperation.(BlockMode).getBlockModeName() = "ECB" implies not cryptoOperation instanceof KeyWrapOperation) and
    exists(string modeName | modeName = cryptoOperation.(BlockMode).getBlockModeName() |
      // Only allow CBC, CTS, and XTS modes as per security requirements
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
    // Check for SymmetricCipher instances without a specified block mode
    cryptoOperation instanceof SymmetricCipher and
    not cryptoOperation.(SymmetricCipher).hasBlockMode() and
    alertMessage = "Cipher has unspecified block mode algorithm."
  )
select cryptoOperation, alertMessage
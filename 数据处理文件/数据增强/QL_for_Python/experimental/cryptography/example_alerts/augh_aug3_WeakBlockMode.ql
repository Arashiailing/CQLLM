/**
 * @name Weak block mode
 * @description Identifies symmetric encryption block modes that are considered weak, deprecated, or not approved for use.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Select cryptographic components and their associated warning messages
from CryptographicArtifact cryptoComponent, string alertMessage
where
  // Filter out false positives by excluding results from cryptography/hazmat paths
  // This is crucial because ECB mode may be used internally in keywrap operations
  not cryptoComponent.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // First case: Analyze BlockMode instances
    cryptoComponent instanceof BlockMode and
    // ECB mode is permitted only for KeyWrapOperations
    (cryptoComponent.(BlockMode).getBlockModeName() = "ECB" implies 
     not cryptoComponent instanceof KeyWrapOperation) and
    exists(string modeIdentifier | modeIdentifier = cryptoComponent.(BlockMode).getBlockModeName() |
      // Only CBC, CTS, and XTS modes are considered approved
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not modeIdentifier = ["CBC", "CTS", "XTS"] and
      if modeIdentifier = unknownAlgorithm()
      then alertMessage = "Detected usage of an unrecognized block mode algorithm."
      else
        if modeIdentifier in ["GCM", "CCM"]
        then
          alertMessage =
            "Usage of block mode algorithm " + modeIdentifier +
              " requires special cryptographic board approval/review."
        else alertMessage = "Detected usage of unapproved block mode algorithm or API " + modeIdentifier + "."
    )
    or
    // Second case: Analyze SymmetricCipher instances lacking a specified block mode
    cryptoComponent instanceof SymmetricCipher and
    not cryptoComponent.(SymmetricCipher).hasBlockMode() and
    alertMessage = "Cipher implementation has unspecified block mode algorithm."
  )
select cryptoComponent, alertMessage
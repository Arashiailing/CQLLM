/**
 * @name Weak block mode detection
 * @description Identifies symmetric encryption operations utilizing weak, obsolete, or unapproved block cipher modes.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Identify cryptographic artifacts and generate corresponding security alerts
from CryptographicArtifact cryptoArtifact, string alertMessage
where
  // Exclude false positives from cryptography/hazmat module paths
  // Particularly relevant for ECB mode usage in key wrapping operations
  not cryptoArtifact.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Evaluate block cipher mode operations
    cryptoArtifact instanceof BlockMode and
    exists(string modeName | modeName = cryptoArtifact.(BlockMode).getBlockModeName() |
      // ECB mode only permitted for key wrapping operations
      (modeName = "ECB" implies not cryptoArtifact instanceof KeyWrapOperation) and
      // Only CBC, CTS, and XTS modes are approved
      // Reference: Microsoft Security Cryptography Requirements 10002
      not modeName = ["CBC", "CTS", "XTS"] and
      // Generate alert based on specific mode characteristics
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
    // Detect symmetric ciphers without specified block mode
    cryptoArtifact instanceof SymmetricCipher and
    not cryptoArtifact.(SymmetricCipher).hasBlockMode() and
    alertMessage = "Cipher has unspecified block mode algorithm."
  )
select cryptoArtifact, alertMessage
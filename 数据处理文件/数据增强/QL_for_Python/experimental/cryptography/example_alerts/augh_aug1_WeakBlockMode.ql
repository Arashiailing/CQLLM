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

// Select encryption operations and corresponding security alerts
from CryptographicArtifact encryptionOperation, string securityAlert
where
  // Exclude false positives from cryptography/hazmat paths
  // (e.g., ECB usage inside keywrap operations)
  not encryptionOperation.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Check for weak or unapproved block modes
    encryptionOperation instanceof BlockMode and
    // ECB mode is only permitted in KeyWrapOperations
    (encryptionOperation.(BlockMode).getBlockModeName() = "ECB" implies 
      not encryptionOperation instanceof KeyWrapOperation) and
    exists(string blockModeName | blockModeName = encryptionOperation.(BlockMode).getBlockModeName() |
      // Only CBC, CTS, and XTS modes are approved without restrictions
      // Reference: Microsoft.Security.Cryptography.10002
      not blockModeName = ["CBC", "CTS", "XTS"] and
      if blockModeName = unknownAlgorithm()
      then securityAlert = "Use of unrecognized block mode algorithm."
      else
        // GCM and CCM modes require special approval
        if blockModeName in ["GCM", "CCM"]
        then
          securityAlert =
            "Use of block mode algorithm " + blockModeName +
              " requires special crypto board approval/review."
        // Other modes are unapproved
        else securityAlert = "Use of unapproved block mode algorithm or API " + blockModeName + "."
    )
    or
    // Check for symmetric ciphers without specified block mode
    encryptionOperation instanceof SymmetricCipher and
    not encryptionOperation.(SymmetricCipher).hasBlockMode() and
    securityAlert = "Cipher has unspecified block mode algorithm."
  )
select encryptionOperation, securityAlert
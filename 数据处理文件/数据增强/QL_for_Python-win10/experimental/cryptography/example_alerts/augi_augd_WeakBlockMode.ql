/**
 * @name Weak block mode
 * @description Detects symmetric encryption block modes that are considered weak, deprecated, or not approved for secure use.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Select encryption components and their corresponding security warnings
from CryptographicArtifact encryptionComponent, string securityWarning
where
  // Filter out false positives in cryptography/hazmat paths
  not encryptionComponent.asExpr()
    .getLocation()
    .getFile()
    .getAbsolutePath()
    .toString()
    .matches("%cryptography/hazmat/%") and
  (
    // Case 1: Check for weak block mode instances
    encryptionComponent instanceof BlockMode and
    // ECB mode is only allowed for key wrap operations
    (encryptionComponent.(BlockMode).getBlockModeName() = "ECB" implies not encryptionComponent instanceof KeyWrapOperation) and
    exists(string blockModeName | 
      blockModeName = encryptionComponent.(BlockMode).getBlockModeName() and
      // Only CBC, CTS, and XTS are approved
      not blockModeName = ["CBC", "CTS", "XTS"] and
      // Determine appropriate warning message based on the block mode
      (
        blockModeName = unknownAlgorithm() and
        securityWarning = "Use of unrecognized block mode algorithm."
        or
        blockModeName in ["GCM", "CCM"] and
        securityWarning = "Use of block mode algorithm " + blockModeName + " requires special crypto board approval/review."
        or
        securityWarning = "Use of unapproved block mode algorithm or API " + blockModeName + "."
      )
    )
    or
    // Case 2: Check for symmetric cipher instances without specified block mode
    encryptionComponent instanceof SymmetricCipher and
    not encryptionComponent.(SymmetricCipher).hasBlockMode() and
    securityWarning = "Cipher has unspecified block mode algorithm."
  )
select encryptionComponent, securityWarning
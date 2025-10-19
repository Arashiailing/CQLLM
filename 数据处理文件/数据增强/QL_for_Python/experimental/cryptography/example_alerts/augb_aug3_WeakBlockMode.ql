/**
 * @name Weak block mode
 * @description Identifies symmetric encryption block modes that are considered weak, obsolete, or otherwise unapproved.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Select cryptographic components and corresponding security alerts
from CryptographicArtifact cryptoComponent, string alertMessage
where
  // Filter out false positives from cryptography/hazmat paths
  // This is crucial for ECB mode used internally in keywrap operations
  not cryptoComponent.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Scenario 1: Check for BlockMode instances with security issues
    cryptoComponent instanceof BlockMode and
    // ECB mode is only allowed for KeyWrapOperations
    (cryptoComponent.(BlockMode).getBlockModeName() = "ECB" implies 
     not cryptoComponent instanceof KeyWrapOperation) and
    exists(string blockModeName | 
      blockModeName = cryptoComponent.(BlockMode).getBlockModeName() and
      // Only CBC, CTS, and XTS modes are approved
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not blockModeName = ["CBC", "CTS", "XTS"] and
      // Generate appropriate alert message based on the block mode
      (
        blockModeName = unknownAlgorithm() and
        alertMessage = "Use of unrecognized block mode algorithm."
        or
        blockModeName in ["GCM", "CCM"] and
        alertMessage =
          "Use of block mode algorithm " + blockModeName +
            " requires special crypto board approval/review."
        or
        alertMessage = "Use of unapproved block mode algorithm or API " + blockModeName + "."
      )
    )
    or
    // Scenario 2: Check for SymmetricCipher instances without a specified block mode
    cryptoComponent instanceof SymmetricCipher and
    not cryptoComponent.(SymmetricCipher).hasBlockMode() and
    alertMessage = "Cipher has unspecified block mode algorithm."
  )
select cryptoComponent, alertMessage
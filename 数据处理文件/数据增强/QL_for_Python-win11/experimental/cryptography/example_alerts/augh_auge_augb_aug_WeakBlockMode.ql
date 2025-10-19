/**
 * @name Weak block mode detection
 * @description This query identifies symmetric encryption operations that utilize weak, obsolete, 
 *              or otherwise unapproved block modes, which could lead to security vulnerabilities.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Select cryptographic operations and generate appropriate alert messages
from CryptographicArtifact encryptionOperation, string securityAlert
where
  // Exclude false positives from projects that include the entire cryptography module
  // Filter out results matching the cryptography/hazmat path
  // Particularly important for ECB usage within keywrap operations
  not encryptionOperation.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Case 1: Check if the operation is a BlockMode instance
    encryptionOperation instanceof BlockMode and
    // ECB mode is only allowed for KeyWrapOperations, so alert if ECB is not part of a KeyWrapOperation
    (encryptionOperation.(BlockMode).getBlockModeName() = "ECB" implies not encryptionOperation instanceof KeyWrapOperation) and
    exists(string modeIdentifier | modeIdentifier = encryptionOperation.(BlockMode).getBlockModeName() |
      // Only CBC, CTS, and XTS modes are approved
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not modeIdentifier = ["CBC", "CTS", "XTS"] and
      // Generate appropriate alert message based on the mode type
      (
        modeIdentifier = unknownAlgorithm() and
        securityAlert = "Use of unrecognized block mode algorithm."
        or
        modeIdentifier in ["GCM", "CCM"] and
        securityAlert = "Use of block mode algorithm " + modeIdentifier + " requires special crypto board approval/review."
        or
        securityAlert = "Use of unapproved block mode algorithm or API " + modeIdentifier + "."
      )
    )
    or
    // Case 2: Check if the operation is a SymmetricCipher instance without a specified block mode algorithm
    encryptionOperation instanceof SymmetricCipher and
    not encryptionOperation.(SymmetricCipher).hasBlockMode() and
    securityAlert = "Cipher has unspecified block mode algorithm."
  )
select encryptionOperation, securityAlert
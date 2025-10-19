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

// Identify cryptographic artifacts and generate corresponding security warnings
from CryptographicArtifact cryptoArtifact, string securityWarning
where
  // Exclude false positives from projects that include the entire cryptography module
  // Filter out results matching the cryptography/hazmat path
  // This is particularly important for ECB usage within keywrap operations
  not cryptoArtifact.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Case 1: The artifact is a BlockMode instance
    cryptoArtifact instanceof BlockMode and
    // ECB mode is only allowed for KeyWrapOperations, so alert if ECB is not part of a KeyWrapOperation
    (cryptoArtifact.(BlockMode).getBlockModeName() = "ECB" implies not cryptoArtifact instanceof KeyWrapOperation) and
    exists(string blockModeType | blockModeType = cryptoArtifact.(BlockMode).getBlockModeName() |
      // Only CBC, CTS, and XTS modes are approved
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not blockModeType = ["CBC", "CTS", "XTS"] and
      // Generate appropriate warning message based on the block mode type
      if blockModeType = unknownAlgorithm()
      then securityWarning = "Use of unrecognized block mode algorithm."
      else
        if blockModeType in ["GCM", "CCM"]
        then
          securityWarning =
            "Use of block mode algorithm " + blockModeType +
              " requires special crypto board approval/review."
        else securityWarning = "Use of unapproved block mode algorithm or API " + blockModeType + "."
    )
    or
    // Case 2: The artifact is a SymmetricCipher instance without a specified block mode algorithm
    cryptoArtifact instanceof SymmetricCipher and
    not cryptoArtifact.(SymmetricCipher).hasBlockMode() and
    securityWarning = "Cipher has unspecified block mode algorithm."
  )
select cryptoArtifact, securityWarning
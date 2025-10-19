/**
 * @name Weak block mode
 * @description Identifies symmetric encryption operations that utilize weak, deprecated, or non-compliant block cipher modes.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Identify cryptographic artifacts that violate block mode security requirements
from CryptographicArtifact cryptoArtifact, string securityAlert
where
  // Exclude false positives from cryptography module's hazmat components
  // This filtering is crucial to avoid flagging legitimate ECB usage in keywrap operations
  not cryptoArtifact.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Case 1: BlockMode instance with non-compliant mode
    cryptoArtifact instanceof BlockMode and
    // ECB mode is exclusively allowed within KeyWrapOperations
    (cryptoArtifact.(BlockMode).getBlockModeName() = "ECB" implies not cryptoArtifact instanceof KeyWrapOperation) and
    exists(string blockModeName | blockModeName = cryptoArtifact.(BlockMode).getBlockModeName() |
      // Only CBC, CTS, and XTS modes are approved per security requirements
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not blockModeName = ["CBC", "CTS", "XTS"] and
      // Generate context-specific security alert based on block mode type
      if blockModeName = unknownAlgorithm()
      then securityAlert = "Use of unrecognized block mode algorithm."
      else
        if blockModeName in ["GCM", "CCM"]
        then
          securityAlert =
            "Use of block mode algorithm " + blockModeName +
              " requires special crypto board approval/review."
        else securityAlert = "Use of unapproved block mode algorithm or API " + blockModeName + "."
    )
    or
    // Case 2: SymmetricCipher instance lacking block mode specification
    cryptoArtifact instanceof SymmetricCipher and
    not cryptoArtifact.(SymmetricCipher).hasBlockMode() and
    securityAlert = "Cipher has unspecified block mode algorithm."
  )
select cryptoArtifact, securityAlert
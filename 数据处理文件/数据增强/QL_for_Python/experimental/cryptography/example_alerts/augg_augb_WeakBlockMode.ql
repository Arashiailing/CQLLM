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

// Select cryptographic artifacts and their corresponding security warnings
from CryptographicArtifact cryptoArtifact, string securityWarning
where
  // Exclude false positives by filtering out results from cryptography/hazmat paths
  // This specifically addresses cases where ECB is used internally within keywrap operations
  not cryptoArtifact.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Check for BlockMode instances with potentially weak configurations
    cryptoArtifact instanceof BlockMode and
    // ECB mode is only permitted for KeyWrapOperations
    (cryptoArtifact.(BlockMode).getBlockModeName() = "ECB" implies not cryptoArtifact instanceof KeyWrapOperation) and
    exists(string blockModeName | 
      blockModeName = cryptoArtifact.(BlockMode).getBlockModeName() and
      // Only allow CBC, CTS, and XTS modes as per security requirements
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not blockModeName = ["CBC", "CTS", "XTS"] and
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
    // Check for SymmetricCipher instances without a specified block mode
    cryptoArtifact instanceof SymmetricCipher and
    not cryptoArtifact.(SymmetricCipher).hasBlockMode() and
    securityWarning = "Cipher has unspecified block mode algorithm."
  )
select cryptoArtifact, securityWarning
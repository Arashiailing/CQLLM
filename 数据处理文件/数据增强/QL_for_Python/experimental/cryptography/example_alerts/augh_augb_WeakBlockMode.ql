/**
 * @name Weak block mode
 * @description Detects symmetric encryption block modes that are considered weak, deprecated, or non-compliant with security standards.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Select cryptographic operations and their corresponding security alert messages
from CryptographicArtifact cryptoArtifact, string securityAlert
where
  // Filter out false positives from cryptography/hazmat paths
  // This specifically addresses cases where ECB is used internally within keywrap operations
  not cryptoArtifact.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Analyze BlockMode instances for potentially weak configurations
    cryptoArtifact instanceof BlockMode and
    // ECB mode is only permitted for KeyWrapOperations
    (cryptoArtifact.(BlockMode).getBlockModeName() = "ECB" implies not cryptoArtifact instanceof KeyWrapOperation) and
    exists(string blockModeName | 
      blockModeName = cryptoArtifact.(BlockMode).getBlockModeName() and
      // Only allow CBC, CTS, and XTS modes according to security requirements
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not blockModeName = ["CBC", "CTS", "XTS"] and
      (
        // Case 1: Unrecognized algorithm
        blockModeName = unknownAlgorithm() and
        securityAlert = "Use of unrecognized block mode algorithm."
        or
        // Case 2: Algorithms requiring special approval
        blockModeName in ["GCM", "CCM"] and
        securityAlert = "Use of block mode algorithm " + blockModeName + " requires special crypto board approval/review."
        or
        // Case 3: Other unapproved algorithms
        not blockModeName in ["GCM", "CCM"] and
        not blockModeName = unknownAlgorithm() and
        securityAlert = "Use of unapproved block mode algorithm or API " + blockModeName + "."
      )
    )
    or
    // Detect SymmetricCipher instances without a specified block mode
    cryptoArtifact instanceof SymmetricCipher and
    not cryptoArtifact.(SymmetricCipher).hasBlockMode() and
    securityAlert = "Cipher has unspecified block mode algorithm."
  )
select cryptoArtifact, securityAlert
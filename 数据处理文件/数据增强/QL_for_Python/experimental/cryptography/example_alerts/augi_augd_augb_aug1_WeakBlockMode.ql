/**
 * @name Weak block mode detection
 * @description Identifies symmetric encryption operations using insecure, deprecated, or unapproved block modes
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Helper predicate to identify artifacts in cryptography/hazmat paths
// These paths are excluded to minimize false positives (e.g., ECB in keywrap contexts)
predicate isExcludedHazmatArtifact(CryptographicArtifact cryptoArtifact) {
  cryptoArtifact.asExpr()
    .getLocation()
    .getFile()
    .getAbsolutePath()
    .toString()
    .matches("%cryptography/hazmat/%")
}

// Helper predicate to evaluate block modes for security vulnerabilities
predicate assessBlockModeWeakness(CryptographicArtifact cryptoArtifact, string warningMessage) {
  cryptoArtifact instanceof BlockMode and
  // ECB mode is only allowed in KeyWrapOperation contexts
  (cryptoArtifact.(BlockMode).getBlockModeName() = "ECB" implies 
    not cryptoArtifact instanceof KeyWrapOperation) and
  exists(string modeName | modeName = cryptoArtifact.(BlockMode).getBlockModeName() |
    // Only CBC, CTS, and XTS are considered secure modes
    // Reference: Microsoft.Security.Cryptography.10002
    not modeName = ["CBC", "CTS", "XTS"] and
    (
      modeName = unknownAlgorithm() and
      warningMessage = "Use of unrecognized block mode algorithm."
      or
      modeName in ["GCM", "CCM"] and
      warningMessage = "Use of block mode algorithm " + modeName + 
        " requires special crypto board approval/review."
      or
      not modeName = unknownAlgorithm() and not modeName in ["GCM", "CCM"] and
      warningMessage = "Use of unapproved block mode algorithm or API " + modeName + "."
    )
  )
}

// Helper predicate to detect ciphers without explicitly specified block modes
predicate detectUnspecifiedBlockMode(CryptographicArtifact cryptoArtifact, string warningMessage) {
  cryptoArtifact instanceof SymmetricCipher and
  not cryptoArtifact.(SymmetricCipher).hasBlockMode() and
  warningMessage = "Cipher has unspecified block mode algorithm."
}

// Main query to identify cryptographic artifacts with security issues
from CryptographicArtifact cryptoArtifact, string warningMessage
where
  // Exclude artifacts in cryptography/hazmat paths to reduce false positives
  // (e.g., ECB usage inside keywrap operations)
  not isExcludedHazmatArtifact(cryptoArtifact) and
  (
    // Evaluate weak or unapproved block modes
    assessBlockModeWeakness(cryptoArtifact, warningMessage)
    or
    // Detect ciphers without specified block mode
    detectUnspecifiedBlockMode(cryptoArtifact, warningMessage)
  )
select cryptoArtifact, warningMessage
/**
 * @name Weak block mode detection
 * @description Identifies symmetric encryption operations using weak, obsolete, or unapproved block modes
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Select cryptographic artifacts and corresponding security alert messages
from CryptographicArtifact cryptoArtifact, string securityAlert
where
  // Exclude false positives from cryptography/hazmat paths
  // (e.g., ECB usage inside keywrap operations)
  not isInCryptographyHazmatPath(cryptoArtifact) and
  (
    // Check for weak block cipher modes
    checkWeakBlockModes(cryptoArtifact, securityAlert)
    or
    // Check for ciphers without specified block mode
    checkUnspecifiedBlockMode(cryptoArtifact, securityAlert)
  )
select cryptoArtifact, securityAlert

// Helper predicate to determine if artifact is in cryptography/hazmat path
predicate isInCryptographyHazmatPath(CryptographicArtifact artifact) {
  artifact.asExpr()
    .getLocation()
    .getFile()
    .getAbsolutePath()
    .toString()
    .matches("%cryptography/hazmat/%")
}

// Helper predicate to evaluate block cipher modes for security weaknesses
predicate checkWeakBlockModes(CryptographicArtifact artifact, string alert) {
  artifact instanceof BlockMode and
  // ECB mode is only permitted in KeyWrapOperation contexts
  (artifact.(BlockMode).getBlockModeName() = "ECB" implies 
    not artifact instanceof KeyWrapOperation) and
  exists(string modeName | modeName = artifact.(BlockMode).getBlockModeName() |
    // Only CBC, CTS, and XTS modes are approved
    // Ref: Microsoft.Security.Cryptography.10002
    not modeName = ["CBC", "CTS", "XTS"] and
    (
      modeName = unknownAlgorithm() and
      alert = "Use of unrecognized block mode algorithm."
      or
      modeName in ["GCM", "CCM"] and
      alert = "Use of block mode algorithm " + modeName + " requires special crypto board approval/review."
      or
      not modeName in ["GCM", "CCM"] and
      alert = "Use of unapproved block mode algorithm or API " + modeName + "."
    )
  )
}

// Helper predicate to detect ciphers without specified block mode
predicate checkUnspecifiedBlockMode(CryptographicArtifact artifact, string alert) {
  artifact instanceof SymmetricCipher and
  not artifact.(SymmetricCipher).hasBlockMode() and
  alert = "Cipher has unspecified block mode algorithm."
}
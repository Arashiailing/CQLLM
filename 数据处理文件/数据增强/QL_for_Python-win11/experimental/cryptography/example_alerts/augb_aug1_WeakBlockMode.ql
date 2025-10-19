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

// Select cryptographic artifacts and corresponding security alert messages
from CryptographicArtifact cryptoArtifact, string securityAlert
where
  // Filter out false positives from cryptography/hazmat paths
  // (e.g., ECB usage inside keywrap operations)
  not isCryptographyHazmatPath(cryptoArtifact) and
  (
    // Analyze block cipher modes for weaknesses
    analyzeWeakBlockModes(cryptoArtifact, securityAlert)
    or
    // Check for ciphers without specified block mode
    analyzeUnspecifiedBlockMode(cryptoArtifact, securityAlert)
  )
select cryptoArtifact, securityAlert

// Helper predicate to check if artifact is in cryptography/hazmat path
predicate isCryptographyHazmatPath(CryptographicArtifact artifact) {
  artifact.asExpr()
    .getLocation()
    .getFile()
    .getAbsolutePath()
    .toString()
    .matches("%cryptography/hazmat/%")
}

// Helper predicate to analyze weak block modes
predicate analyzeWeakBlockModes(CryptographicArtifact artifact, string alert) {
  artifact instanceof BlockMode and
  // ECB mode is only allowed in KeyWrapOperation contexts
  (artifact.(BlockMode).getBlockModeName() = "ECB" implies 
    not artifact instanceof KeyWrapOperation) and
  exists(string blockModeName | blockModeName = artifact.(BlockMode).getBlockModeName() |
    // Only CBC, CTS, and XTS modes are approved
    // Ref: Microsoft.Security.Cryptography.10002
    not blockModeName = ["CBC", "CTS", "XTS"] and
    if blockModeName = unknownAlgorithm()
    then alert = "Use of unrecognized block mode algorithm."
    else
      if blockModeName in ["GCM", "CCM"]
      then
        alert =
          "Use of block mode algorithm " + blockModeName +
            " requires special crypto board approval/review."
      else alert = "Use of unapproved block mode algorithm or API " + blockModeName + "."
  )
}

// Helper predicate to analyze ciphers without specified block mode
predicate analyzeUnspecifiedBlockMode(CryptographicArtifact artifact, string alert) {
  artifact instanceof SymmetricCipher and
  not artifact.(SymmetricCipher).hasBlockMode() and
  alert = "Cipher has unspecified block mode algorithm."
}
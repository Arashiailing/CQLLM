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

// Helper predicate to identify artifacts in cryptography/hazmat paths
// These paths are typically excluded to reduce false positives
predicate isInCryptographyHazmatPath(CryptographicArtifact cryptoComponent) {
  cryptoComponent.asExpr()
    .getLocation()
    .getFile()
    .getAbsolutePath()
    .toString()
    .matches("%cryptography/hazmat/%")
}

// Helper predicate to evaluate block modes for security weaknesses
predicate evaluateWeakBlockModes(CryptographicArtifact cryptoComponent, string alertMessage) {
  cryptoComponent instanceof BlockMode and
  // ECB mode is only permitted in KeyWrapOperation contexts
  (cryptoComponent.(BlockMode).getBlockModeName() = "ECB" implies 
    not cryptoComponent instanceof KeyWrapOperation) and
  exists(string modeName | modeName = cryptoComponent.(BlockMode).getBlockModeName() |
    // Only CBC, CTS, and XTS modes are considered secure
    // Reference: Microsoft.Security.Cryptography.10002
    not modeName = ["CBC", "CTS", "XTS"] and
    if modeName = unknownAlgorithm()
    then alertMessage = "Use of unrecognized block mode algorithm."
    else
      if modeName in ["GCM", "CCM"]
      then
        alertMessage =
          "Use of block mode algorithm " + modeName +
            " requires special crypto board approval/review."
      else alertMessage = "Use of unapproved block mode algorithm or API " + modeName + "."
  )
}

// Helper predicate to check for ciphers without explicitly specified block modes
predicate checkUnspecifiedBlockMode(CryptographicArtifact cryptoComponent, string alertMessage) {
  cryptoComponent instanceof SymmetricCipher and
  not cryptoComponent.(SymmetricCipher).hasBlockMode() and
  alertMessage = "Cipher has unspecified block mode algorithm."
}

// Main query to select cryptographic artifacts with security issues
from CryptographicArtifact encryptionArtifact, string alertMessage
where
  // Exclude artifacts in cryptography/hazmat paths to reduce false positives
  // (e.g., ECB usage inside keywrap operations)
  not isInCryptographyHazmatPath(encryptionArtifact) and
  (
    // Check for weak or unapproved block modes
    evaluateWeakBlockModes(encryptionArtifact, alertMessage)
    or
    // Check for ciphers without specified block mode
    checkUnspecifiedBlockMode(encryptionArtifact, alertMessage)
  )
select encryptionArtifact, alertMessage
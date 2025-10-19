/**
 * @name Weak block mode
 * @description Detects symmetric encryption operations utilizing weak, deprecated, or unauthorized block cipher modes
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Helper predicate to determine if a cryptographic artifact is located within the cryptography/hazmat module
predicate isCryptographyHazmatPath(CryptographicArtifact cryptoArtifact) {
  cryptoArtifact.asExpr()
    .getLocation()
    .getFile()
    .getAbsolutePath()
    .toString()
    .matches("%cryptography/hazmat/%")
}

// Helper predicate to evaluate block cipher modes for security vulnerabilities
predicate analyzeWeakBlockModes(CryptographicArtifact cryptoArtifact, string alertMessage) {
  cryptoArtifact instanceof BlockMode and
  // ECB mode is only permitted within KeyWrapOperation contexts
  (cryptoArtifact.(BlockMode).getBlockModeName() = "ECB" implies 
    not cryptoArtifact instanceof KeyWrapOperation) and
  exists(string modeName | modeName = cryptoArtifact.(BlockMode).getBlockModeName() |
    // Only CBC, CTS, and XTS modes are authorized for use
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

// Helper predicate to identify symmetric ciphers lacking explicit block mode specification
predicate analyzeUnspecifiedBlockMode(CryptographicArtifact cryptoArtifact, string alertMessage) {
  cryptoArtifact instanceof SymmetricCipher and
  not cryptoArtifact.(SymmetricCipher).hasBlockMode() and
  alertMessage = "Cipher has unspecified block mode algorithm."
}

// Main query selecting cryptographic operations and corresponding security alert messages
from CryptographicArtifact cryptoArtifact, string alertMessage
where
  // Exclude false positives originating from cryptography/hazmat paths
  // (e.g., ECB usage within keywrap operations)
  not isCryptographyHazmatPath(cryptoArtifact) and
  (
    // Evaluate block cipher modes for potential weaknesses
    analyzeWeakBlockModes(cryptoArtifact, alertMessage)
    or
    // Detect ciphers without explicitly defined block modes
    analyzeUnspecifiedBlockMode(cryptoArtifact, alertMessage)
  )
select cryptoArtifact, alertMessage
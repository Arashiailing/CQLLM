/**
 * @name Weak block mode detection
 * @description Detects symmetric encryption operations utilizing weak, deprecated, or non-compliant block cipher modes
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Identify cryptographic elements and their associated security warnings
from CryptographicArtifact cryptoElement, string alertMessage
where
  // Exclude false positives originating from cryptography/hazmat paths
  // (specifically ECB usage within key wrapping operations)
  not isInHazmatCryptoPath(cryptoElement) and
  (
    // Evaluate block cipher modes for security vulnerabilities
    evaluateWeakBlockModes(cryptoElement, alertMessage)
    or
    // Detect ciphers operating without explicit block mode specification
    evaluateMissingBlockMode(cryptoElement, alertMessage)
  )
select cryptoElement, alertMessage

// Helper predicate to determine if component resides in cryptography/hazmat directory
predicate isInHazmatCryptoPath(CryptographicArtifact cryptoComponent) {
  cryptoComponent.asExpr()
    .getLocation()
    .getFile()
    .getAbsolutePath()
    .toString()
    .matches("%cryptography/hazmat/%")
}

// Helper predicate to evaluate cryptographic components for weak block modes
predicate evaluateWeakBlockModes(CryptographicArtifact cryptoComponent, string warningMsg) {
  cryptoComponent instanceof BlockMode and
  // ECB mode is permissible only within KeyWrapOperation contexts
  (cryptoComponent.(BlockMode).getBlockModeName() = "ECB" implies 
    not cryptoComponent instanceof KeyWrapOperation) and
  exists(string modeIdentifier | modeIdentifier = cryptoComponent.(BlockMode).getBlockModeName() |
    // Only CBC, CTS, and XTS modes are considered approved
    // Reference: Microsoft.Security.Cryptography.10002
    not modeIdentifier = ["CBC", "CTS", "XTS"] and
    if modeIdentifier = unknownAlgorithm()
    then warningMsg = "Unrecognized block mode algorithm detected."
    else
      if modeIdentifier in ["GCM", "CCM"]
      then
        warningMsg =
          "Block mode algorithm " + modeIdentifier +
            " requires special cryptographic board approval."
      else warningMsg = "Non-compliant block mode algorithm or API detected: " + modeIdentifier + "."
  )
}

// Helper predicate to evaluate cryptographic components for missing block mode specification
predicate evaluateMissingBlockMode(CryptographicArtifact cryptoComponent, string warningMsg) {
  cryptoComponent instanceof SymmetricCipher and
  not cryptoComponent.(SymmetricCipher).hasBlockMode() and
  warningMsg = "Cipher operation lacks explicit block mode specification."
}
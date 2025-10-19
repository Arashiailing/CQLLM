/**
 * @name Weak block mode
 * @description Identifies symmetric encryption operations using weak, deprecated, or unauthorized block cipher modes
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Determines if a cryptographic object is located within the cryptography/hazmat module
predicate isInCryptographyHazmatModule(CryptographicArtifact cryptoObj) {
  cryptoObj.asExpr()
    .getLocation()
    .getFile()
    .getAbsolutePath()
    .toString()
    .matches("%cryptography/hazmat/%")
}

// Evaluates block cipher modes for security vulnerabilities and generates appropriate alert messages
predicate checkForWeakBlockModes(CryptographicArtifact cryptoObj, string securityAlert) {
  cryptoObj instanceof BlockMode and
  // ECB mode is only allowed within KeyWrapOperation contexts
  (cryptoObj.(BlockMode).getBlockModeName() = "ECB" implies 
    not cryptoObj instanceof KeyWrapOperation) and
  exists(string blockModeName | blockModeName = cryptoObj.(BlockMode).getBlockModeName() |
    // Only CBC, CTS, and XTS modes are authorized for use
    // Reference: Microsoft.Security.Cryptography.10002
    not blockModeName = ["CBC", "CTS", "XTS"] and
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
}

// Identifies symmetric ciphers that lack explicit block mode specification
predicate checkForUnspecifiedBlockMode(CryptographicArtifact cryptoObj, string securityAlert) {
  cryptoObj instanceof SymmetricCipher and
  not cryptoObj.(SymmetricCipher).hasBlockMode() and
  securityAlert = "Cipher has unspecified block mode algorithm."
}

// Main query that selects cryptographic operations and their corresponding security alert messages
from CryptographicArtifact cryptoObj, string securityAlert
where
  // Exclude false positives from cryptography/hazmat paths
  // (e.g., ECB usage within keywrap operations)
  not isInCryptographyHazmatModule(cryptoObj) and
  (
    // Check for weak or unauthorized block cipher modes
    checkForWeakBlockModes(cryptoObj, securityAlert)
    or
    // Detect ciphers without explicitly defined block modes
    checkForUnspecifiedBlockMode(cryptoObj, securityAlert)
  )
select cryptoObj, securityAlert
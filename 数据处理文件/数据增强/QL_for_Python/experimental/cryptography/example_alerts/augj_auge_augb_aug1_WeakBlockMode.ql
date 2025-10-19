/**
 * @name Weak block mode detection
 * @description Identifies symmetric encryption operations that use weak, deprecated, or unauthorized block cipher modes
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

/**
 * Determines if a cryptographic operation is located within the cryptography/hazmat module.
 * This helps exclude false positives from low-level cryptographic implementations.
 */
predicate isHazmatModulePath(CryptographicArtifact cryptoOperation) {
  cryptoOperation.asExpr()
    .getLocation()
    .getFile()
    .getAbsolutePath()
    .toString()
    .matches("%cryptography/hazmat/%")
}

/**
 * Evaluates block cipher modes for security vulnerabilities.
 * Generates appropriate security alerts based on the detected block mode.
 */
predicate checkBlockModeSecurity(CryptographicArtifact cryptoOperation, string securityAlert) {
  cryptoOperation instanceof BlockMode and
  // ECB mode is only permitted within KeyWrapOperation contexts
  (cryptoOperation.(BlockMode).getBlockModeName() = "ECB" implies 
    not cryptoOperation instanceof KeyWrapOperation) and
  exists(string blockModeName | blockModeName = cryptoOperation.(BlockMode).getBlockModeName() |
    // Only CBC, CTS, and XTS modes are authorized for general use
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

/**
 * Identifies symmetric ciphers that lack explicit block mode specification.
 * Such ciphers may default to insecure modes or behavior.
 */
predicate detectMissingBlockMode(CryptographicArtifact cryptoOperation, string securityAlert) {
  cryptoOperation instanceof SymmetricCipher and
  not cryptoOperation.(SymmetricCipher).hasBlockMode() and
  securityAlert = "Cipher has unspecified block mode algorithm."
}

// Main query logic: combines all security checks for block cipher modes
from CryptographicArtifact cryptoOperation, string securityAlert
where
  // Exclude false positives from cryptography/hazmat module paths
  not isHazmatModulePath(cryptoOperation) and
  (
    // Check for weak or unauthorized block cipher modes
    checkBlockModeSecurity(cryptoOperation, securityAlert)
    or
    // Detect ciphers without explicitly defined block modes
    detectMissingBlockMode(cryptoOperation, securityAlert)
  )
select cryptoOperation, securityAlert
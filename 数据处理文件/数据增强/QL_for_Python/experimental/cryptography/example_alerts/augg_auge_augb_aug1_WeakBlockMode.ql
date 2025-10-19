/**
 * @name Weak block mode
 * @description Identifies symmetric encryption operations that utilize weak, deprecated, or unauthorized block cipher modes
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Helper predicate to determine if a cryptographic element is located within the cryptography/hazmat module
predicate isCryptographyHazmatPath(CryptographicArtifact cryptoElement) {
  cryptoElement.asExpr()
    .getLocation()
    .getFile()
    .getAbsolutePath()
    .toString()
    .matches("%cryptography/hazmat/%")
}

// Helper predicate to evaluate block cipher modes for security vulnerabilities
predicate analyzeBlockModeSecurityIssues(CryptographicArtifact cryptoElement, string securityAlert) {
  // Case 1: Check for weak or unauthorized block modes
  (cryptoElement instanceof BlockMode and
    // ECB mode is only permitted within KeyWrapOperation contexts
    (cryptoElement.(BlockMode).getBlockModeName() = "ECB" implies 
      not cryptoElement instanceof KeyWrapOperation) and
    exists(string blockModeName | 
      blockModeName = cryptoElement.(BlockMode).getBlockModeName() and
      // Only CBC, CTS, and XTS modes are authorized for use
      // Reference: Microsoft.Security.Cryptography.10002
      not blockModeName = ["CBC", "CTS", "XTS"] and
      if blockModeName = unknownAlgorithm()
      then securityAlert = "Use of unrecognized block mode algorithm."
      else
        if blockModeName in ["GCM", "CCM"]
        then securityAlert = "Use of block mode algorithm " + blockModeName + " requires special crypto board approval/review."
        else securityAlert = "Use of unapproved block mode algorithm or API " + blockModeName + "."
    ))
  or
  // Case 2: Check for ciphers without explicitly defined block modes
  (cryptoElement instanceof SymmetricCipher and
    not cryptoElement.(SymmetricCipher).hasBlockMode() and
    securityAlert = "Cipher has unspecified block mode algorithm.")
}

// Main query selecting cryptographic operations and corresponding security alert messages
from CryptographicArtifact cryptoElement, string securityAlert
where
  // Exclude false positives originating from cryptography/hazmat paths
  // (e.g., ECB usage within keywrap operations)
  not isCryptographyHazmatPath(cryptoElement) and
  // Evaluate block cipher modes for potential security issues
  analyzeBlockModeSecurityIssues(cryptoElement, securityAlert)
select cryptoElement, securityAlert
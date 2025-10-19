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

/**
 * Determines if a cryptographic element is located within the cryptography/hazmat module.
 * This module contains low-level cryptographic implementations that may use otherwise
 * discouraged modes for specific purposes, so we exclude them from our analysis.
 */
predicate isInCryptographyHazmatModule(CryptographicArtifact cryptographicElement) {
  cryptographicElement.asExpr()
    .getLocation()
    .getFile()
    .getAbsolutePath()
    .toString()
    .matches("%cryptography/hazmat/%")
}

/**
 * Evaluates block cipher modes for security vulnerabilities.
 * This predicate identifies two main security issues:
 * 1. Use of weak or unauthorized block cipher modes
 * 2. Use of symmetric ciphers without explicitly defined block modes
 */
predicate evaluateBlockModeSecurity(CryptographicArtifact cryptographicElement, string securityWarning) {
  // Check for weak or unauthorized block modes
  (cryptographicElement instanceof BlockMode and
    // ECB mode is only permitted within KeyWrapOperation contexts
    (cryptographicElement.(BlockMode).getBlockModeName() = "ECB" implies 
      not cryptographicElement instanceof KeyWrapOperation) and
    exists(string blockCipherMode | 
      blockCipherMode = cryptographicElement.(BlockMode).getBlockModeName() and
      // Only CBC, CTS, and XTS modes are authorized for general use
      // Reference: Microsoft.Security.Cryptography.10002
      not blockCipherMode = ["CBC", "CTS", "XTS"] and
      // Generate appropriate security warning based on the block mode
      if blockCipherMode = unknownAlgorithm()
      then securityWarning = "Use of unrecognized block mode algorithm."
      else
        if blockCipherMode in ["GCM", "CCM"]
        then securityWarning = "Use of block mode algorithm " + blockCipherMode + " requires special crypto board approval/review."
        else securityWarning = "Use of unapproved block mode algorithm or API " + blockCipherMode + "."
    ))
  or
  // Check for ciphers without explicitly defined block modes
  (cryptographicElement instanceof SymmetricCipher and
    not cryptographicElement.(SymmetricCipher).hasBlockMode() and
    securityWarning = "Cipher has unspecified block mode algorithm.")
}

// Main query: selects cryptographic operations with security issues and corresponding warning messages
from CryptographicArtifact cryptographicElement, string securityWarning
where
  // Exclude false positives from cryptography/hazmat module
  not isInCryptographyHazmatModule(cryptographicElement) and
  // Identify block mode security issues
  evaluateBlockModeSecurity(cryptographicElement, securityWarning)
select cryptographicElement, securityWarning
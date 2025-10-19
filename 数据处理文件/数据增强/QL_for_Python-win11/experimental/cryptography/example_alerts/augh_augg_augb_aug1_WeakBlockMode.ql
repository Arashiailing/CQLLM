/**
 * @name Weak Block Mode Detection
 * @description Identifies symmetric encryption operations that utilize weak, obsolete, or unapproved block cipher modes
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Select cryptographic elements and corresponding security alert messages
from CryptographicArtifact cryptoElement, string alertMessage
where
  // Exclude false positives from cryptography/hazmat paths
  // (e.g., ECB usage inside keywrap operations)
  not isInCryptographyHazmatPath(cryptoElement) and
  (
    // Check for weak block cipher modes
    checkWeakBlockModes(cryptoElement, alertMessage)
    or
    // Check for ciphers without specified block mode
    checkUnspecifiedBlockMode(cryptoElement, alertMessage)
  )
select cryptoElement, alertMessage

// Helper predicate to determine if element is in cryptography/hazmat path
predicate isInCryptographyHazmatPath(CryptographicArtifact cryptoItem) {
  cryptoItem.asExpr()
    .getLocation()
    .getFile()
    .getAbsolutePath()
    .toString()
    .matches("%cryptography/hazmat/%")
}

// Helper predicate to evaluate block cipher modes for security weaknesses
predicate checkWeakBlockModes(CryptographicArtifact cryptoItem, string warningMsg) {
  // Ensure we're dealing with a block mode
  cryptoItem instanceof BlockMode and
  
  // ECB mode is only permitted in KeyWrapOperation contexts
  (cryptoItem.(BlockMode).getBlockModeName() = "ECB" implies 
    not cryptoItem instanceof KeyWrapOperation) and
    
  // Check if the block mode is weak or unapproved
  exists(string blockModeName | 
    blockModeName = cryptoItem.(BlockMode).getBlockModeName() |
    // Only CBC, CTS, and XTS modes are approved
    // Ref: Microsoft.Security.Cryptography.10002
    not blockModeName = ["CBC", "CTS", "XTS"] and
    (
      // Case 1: Unrecognized algorithm
      blockModeName = unknownAlgorithm() and
      warningMsg = "Use of unrecognized block mode algorithm."
      
      or
      
      // Case 2: GCM/CCM modes require special approval
      blockModeName in ["GCM", "CCM"] and
      warningMsg = "Use of block mode algorithm " + blockModeName + " requires special crypto board approval/review."
      
      or
      
      // Case 3: Other unapproved modes
      not blockModeName in ["GCM", "CCM"] and
      warningMsg = "Use of unapproved block mode algorithm or API " + blockModeName + "."
    )
  )
}

// Helper predicate to detect ciphers without specified block mode
predicate checkUnspecifiedBlockMode(CryptographicArtifact cryptoItem, string warningMsg) {
  cryptoItem instanceof SymmetricCipher and
  not cryptoItem.(SymmetricCipher).hasBlockMode() and
  warningMsg = "Cipher has unspecified block mode algorithm."
}
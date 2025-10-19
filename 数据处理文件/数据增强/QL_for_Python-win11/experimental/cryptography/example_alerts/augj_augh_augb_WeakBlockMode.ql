/**
 * @name Weak block mode
 * @description Identifies symmetric encryption block modes that are classified as weak, deprecated, or non-compliant with established security standards.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Identify encryption elements and their corresponding security warning messages
from CryptographicArtifact encryptionElement, string warningMessage
where
  // Exclude false positives originating from cryptography/hazmat paths
  // This specifically mitigates cases where ECB mode is utilized internally within keywrap operations
  not encryptionElement.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Examination of BlockMode instances for potentially insecure configurations
    encryptionElement instanceof BlockMode and
    // ECB mode is exclusively permitted for KeyWrapOperations
    (encryptionElement.(BlockMode).getBlockModeName() = "ECB" implies not encryptionElement instanceof KeyWrapOperation) and
    exists(string modeIdentifier | 
      modeIdentifier = encryptionElement.(BlockMode).getBlockModeName() and
      // Permissible modes restricted to CBC, CTS, and XTS per security guidelines
      // Reference: https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not modeIdentifier = ["CBC", "CTS", "XTS"] and
      (
        // Scenario 1: Detection of unrecognized algorithm
        modeIdentifier = unknownAlgorithm() and
        warningMessage = "Use of unrecognized block mode algorithm."
        or
        // Scenario 2: Algorithms requiring special approval process
        modeIdentifier in ["GCM", "CCM"] and
        warningMessage = "Use of block mode algorithm " + modeIdentifier + " requires special crypto board approval/review."
        or
        // Scenario 3: Detection of other unapproved algorithms
        not modeIdentifier in ["GCM", "CCM"] and
        not modeIdentifier = unknownAlgorithm() and
        warningMessage = "Use of unapproved block mode algorithm or API " + modeIdentifier + "."
      )
    )
    or
    // Detection of SymmetricCipher instances lacking explicit block mode specification
    encryptionElement instanceof SymmetricCipher and
    not encryptionElement.(SymmetricCipher).hasBlockMode() and
    warningMessage = "Cipher has unspecified block mode algorithm."
  )
select encryptionElement, warningMessage
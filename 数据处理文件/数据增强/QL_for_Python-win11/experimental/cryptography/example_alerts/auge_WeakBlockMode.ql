/**
 * @name Weak symmetric encryption block mode
 * @description Detects the usage of symmetric encryption block modes that are considered weak, deprecated, or not approved for use.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Select cryptographic operations and corresponding warning messages
from CryptographicArtifact cryptoOperation, string warningMessage
where
  // Exclude false positives by filtering out code within cryptography/hazmat paths
  // This specifically addresses cases where ECB might be used internally within keywrap operations
  not cryptoOperation.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // Check if the operation uses a block cipher mode
    cryptoOperation instanceof BlockMode and
    // ECB mode is only permitted for key wrap operations; flag ECB when not used in key wrap
    (cryptoOperation.(BlockMode).getBlockModeName() = "ECB" implies not cryptoOperation instanceof KeyWrapOperation) and
    exists(string modeName | modeName = cryptoOperation.(BlockMode).getBlockModeName() |
      // Only CBC, CTS, and XTS modes are approved
      // Reference: Microsoft Security Cryptography Requirements
      not modeName = ["CBC", "CTS", "XTS"] and
      if modeName = unknownAlgorithm()
      then warningMessage = "Use of unrecognized block mode algorithm."
      else
        if modeName in ["GCM", "CCM"]
        then
          warningMessage =
            "Use of block mode algorithm " + modeName +
              " requires special crypto board approval/review."
        else warningMessage = "Use of unapproved block mode algorithm or API " + modeName + "."
    )
    or
    // Check if the operation is a symmetric cipher without a specified block mode
    cryptoOperation instanceof SymmetricCipher and
    not cryptoOperation.(SymmetricCipher).hasBlockMode() and
    warningMessage = "Cipher has unspecified block mode algorithm."
  )
select cryptoOperation, warningMessage
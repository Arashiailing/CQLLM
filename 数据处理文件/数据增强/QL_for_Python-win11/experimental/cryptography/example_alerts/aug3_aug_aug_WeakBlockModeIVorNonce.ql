/**
 * @name Weak block mode IV or nonce
 * @description Detects vulnerable initialization vector (IV) or nonce usage in block cipher operations.
 *              Highlights cases where IVs/nonces are absent or not generated using os.urandom.
 *              Fernet is excluded (manages IV internally), and complex cases need manual verification.
 *
 *            NOTE: This query flags any IV/nonce not originating from os.urandom or with unclear sources.
 *                  Sophisticated patterns (e.g., GCM nonce usage) require expert analysis. Functions that
 *                  infer both mode and IV might cause false positives (addressed via suppression).
 *                  Fernet is explicitly excluded due to its internal os.urandom implementation.
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify block cipher modes with weak IV/nonce configurations
from BlockMode blockCipherMode, string alertMessage, DataFlow::Node originNode
where
  // Exclude Fernet as it handles IV generation internally
  not blockCipherMode instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet and
  (
    // Check for missing IV/nonce OR non-os.urandom source
    not blockCipherMode.hasIVorNonce() or
    not API::moduleImport("os").getMember("urandom").getACall() = blockCipherMode.getIVorNonce()
  ) and
  // Determine diagnostic details based on IV/nonce presence
  (
    // Handle case where IV/nonce is missing
    if not blockCipherMode.hasIVorNonce()
    then (
      originNode = blockCipherMode and 
      alertMessage = "Block mode is missing IV/Nonce initialization."
    )
    // Handle case where IV/nonce is from insecure source
    else (
      originNode = blockCipherMode.getIVorNonce()
    )
  ) and
  // Finalize diagnostic message with source reference
  alertMessage = "Block mode is not using an accepted IV/Nonce initialization: $@"
select blockCipherMode, alertMessage, originNode, originNode.toString()
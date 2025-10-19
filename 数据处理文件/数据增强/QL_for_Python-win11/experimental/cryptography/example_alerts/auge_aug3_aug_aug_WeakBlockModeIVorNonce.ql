/**
 * @name Weak block mode IV or nonce
 * @description Detects vulnerable initialization vector (IV) or nonce usage in block cipher operations.
 *              This query identifies cases where IVs/nonces are either missing or not generated
 *              using cryptographically secure methods like os.urandom.
 *              
 *              Fernet encryption is excluded from this check as it manages IV generation internally.
 *              Complex cryptographic patterns may require manual verification by security experts.
 *
 *            NOTE: This query flags any IV/nonce that doesn't originate from os.urandom or has
 *                  an unclear source. Sophisticated nonce usage patterns (e.g., in GCM mode)
 *                  should be reviewed manually. Functions that infer both mode and IV might
 *                  generate false positives - these can be suppressed as needed.
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify block cipher modes with weak IV/nonce configurations
from BlockMode cipherMode, string diagnosticMsg, DataFlow::Node sourceNode
where
  // Exclude Fernet as it handles IV generation internally with os.urandom
  not cipherMode instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet and
  (
    // Check for either missing IV/nonce OR IV/nonce not from os.urandom
    not cipherMode.hasIVorNonce() or
    not API::moduleImport("os").getMember("urandom").getACall() = cipherMode.getIVorNonce()
  ) and
  // Determine diagnostic details based on IV/nonce presence
  (
    // Case 1: IV/nonce is missing
    if not cipherMode.hasIVorNonce()
    then (
      sourceNode = cipherMode and 
      diagnosticMsg = "Block mode is missing IV/Nonce initialization."
    )
    // Case 2: IV/nonce is present but from insecure source
    else (
      sourceNode = cipherMode.getIVorNonce() and
      diagnosticMsg = "Block mode is not using an accepted IV/Nonce initialization: $@"
    )
  )
select cipherMode, diagnosticMsg, sourceNode, sourceNode.toString()
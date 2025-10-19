/**
 * @name Weak block mode IV or nonce
 * @description Identifies vulnerable initialization vectors/nonces in block cipher modes.
 *              Flags IVs/nonces not generated via cryptographically secure methods (os.urandom).
 * 
 *            NOTE:
 *              1. Simplified approach: Any IV/nonce not from os.urandom is flagged
 *              2. Special cases:
 *                 - GCM mode: Requires specific nonce handling (covered in separate query)
 *                 - Fernet: Explicitly excluded (uses os.urandom internally)
 *              3. Functions inferring mode/IV may trigger false positives (user suppression required)
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify block cipher operations with weak IV/nonce configuration
from BlockMode cipherOperation, string alertMsg, DataFlow::Node weakSource
where
  // Exclude Fernet (handles IV generation internally)
  not cipherOperation instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet
  and (
    // Case 1: Missing IV/Nonce initialization
    (
      not cipherOperation.hasIVorNonce() and
      weakSource = cipherOperation and
      alertMsg = "Block mode is missing IV/Nonce initialization"
    )
    or
    // Case 2: Non-os.urandom IV/Nonce source
    (
      cipherOperation.hasIVorNonce() and
      not API::moduleImport("os").getMember("urandom").getACall() = cipherOperation.getIVorNonce() and
      weakSource = cipherOperation.getIVorNonce() and
      alertMsg = "Block mode uses non-cryptographic IV/Nonce source: $@"
    )
  )
select cipherOperation, alertMsg, weakSource, weakSource.toString()
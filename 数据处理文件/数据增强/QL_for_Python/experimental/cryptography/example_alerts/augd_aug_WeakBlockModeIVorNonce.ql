/**
 * @name Weak block mode IV or nonce
 * @description Identifies weak/obsolete initialization vectors or nonces in block cipher modes.
 *              Flags IVs/nonces not generated via cryptographically secure random methods (os.urandom).
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
from BlockMode cipherOperation, string warningMessage, DataFlow::Node vulnerableSource
where
  // Exclude Fernet (handles IV generation internally)
  not cipherOperation instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet
  and (
    // Case 1: Missing IV/Nonce initialization
    if not cipherOperation.hasIVorNonce()
    then (
      vulnerableSource = cipherOperation and
      warningMessage = "Block mode is missing IV/Nonce initialization"
    )
    // Case 2: Non-os.urandom IV/Nonce source
    else (
      not API::moduleImport("os").getMember("urandom").getACall() = cipherOperation.getIVorNonce() and
      vulnerableSource = cipherOperation.getIVorNonce() and
      warningMessage = "Block mode uses non-cryptographic IV/Nonce source: $@"
    )
  )
select cipherOperation, warningMessage, vulnerableSource, vulnerableSource.toString()
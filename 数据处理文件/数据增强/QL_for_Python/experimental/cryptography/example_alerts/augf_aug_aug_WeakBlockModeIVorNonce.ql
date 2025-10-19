/**
 * @name Weak block mode IV or nonce
 * @description Detects insecure initialization vectors/nonces in block cipher operations.
 *              Flags missing IVs/nonces or those not generated via os.urandom.
 *              Excludes Fernet (handled internally) and requires manual review for complex cases.
 *
 *            NOTE: This simplified query flags any IV/nonce not from os.urandom or undetermined origin.
 *                  Nuanced patterns (e.g., GCM nonce usage) require expert review. Functions inferring
 *                  both mode and IV may trigger false positives (handled via suppression). Fernet is
 *                  explicitly excluded due to internal os.urandom usage.
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify block mode operations with weak IV/nonce configurations
from BlockMode cipherOperation, string alertMessage, DataFlow::Node ivSource
where
  // Exclude Fernet (handles IV generation internally)
  not cipherOperation instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet and
  (
    // Detect missing IV/nonce OR non-os.urandom source
    not cipherOperation.hasIVorNonce() or
    not API::moduleImport("os").getMember("urandom").getACall() = cipherOperation.getIVorNonce()
  ) and
  // Assign source node based on IV/nonce presence
  (
    if not cipherOperation.hasIVorNonce()
    then ivSource = cipherOperation 
    else ivSource = cipherOperation.getIVorNonce()
  ) and
  // Generate unified diagnostic message
  alertMessage = "Block mode is not using an accepted IV/Nonce initialization: $@"
select cipherOperation, alertMessage, ivSource, ivSource.toString()
/**
 * @name Weak block mode IV or nonce
 * @description Detects block cipher operations using initialization vectors or nonces
 *              that are not generated through cryptographically secure methods (os.urandom).
 *
 *            IMPORTANT NOTES:
 *              1. Detection methodology: Flags any IV/nonce not derived from os.urandom
 *              2. Exclusions:
 *                 - GCM mode: Requires unique nonce management (covered in separate analysis)
 *                 - Fernet: Excluded from detection (handles secure IV generation internally)
 *              3. Possible false positives: Functions inferring mode/IV may need manual verification
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify block cipher operations with vulnerable IV/nonce configuration
from BlockMode blockCipherOperation, string alertMessage, DataFlow::Node vulnerableSource
where
  // Exclude Fernet encryption (it securely manages IV generation internally)
  not blockCipherOperation instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet
  and
  (
    // Case 1: Operation does not have IV/Nonce initialization
    if not blockCipherOperation.hasIVorNonce()
    then (
      vulnerableSource = blockCipherOperation and
      alertMessage = "Block mode operation missing IV/Nonce initialization"
    )
    // Case 2: IV/Nonce is derived from a non-cryptographic source
    else (
      not API::moduleImport("os").getMember("urandom").getACall() = blockCipherOperation.getIVorNonce() and
      vulnerableSource = blockCipherOperation.getIVorNonce() and
      alertMessage = "Block mode using insecure IV/Nonce source: $@"
    )
  )
select blockCipherOperation, alertMessage, vulnerableSource, vulnerableSource.toString()
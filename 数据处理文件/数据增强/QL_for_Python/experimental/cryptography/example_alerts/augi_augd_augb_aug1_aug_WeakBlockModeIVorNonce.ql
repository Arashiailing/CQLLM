/**
 * @name Weak block mode IV or nonce
 * @description Identifies insecure initialization vectors/nonces in block cipher operations.
 *              Flags IVs/nonces not generated using cryptographically secure methods (os.urandom).
 *
 *            IMPORTANT NOTES:
 *              1. Simplified detection: Any IV/nonce not originating from os.urandom is flagged
 *              2. Special handling:
 *                 - GCM mode: Requires unique nonce management (addressed in separate query)
 *                 - Fernet: Excluded from analysis (implements secure IV generation internally)
 *              3. Functions dynamically determining mode/IV may yield false positives (manual review needed)
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify block cipher operations with vulnerable IV/nonce configuration
from BlockMode cipherOperation, string securityAlert, DataFlow::Node vulnerableSource
where
  // Exclude Fernet encryption as it handles IV generation securely internally
  not cipherOperation instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet
  and (
    // Case 1: IV/Nonce is completely missing
    not cipherOperation.hasIVorNonce()
    and vulnerableSource = cipherOperation
    and securityAlert = "Block mode is missing IV/Nonce initialization"
    or
    // Case 2: IV/Nonce comes from non-cryptographic source
    cipherOperation.hasIVorNonce()
    and not API::moduleImport("os").getMember("urandom").getACall() = cipherOperation.getIVorNonce()
    and vulnerableSource = cipherOperation.getIVorNonce()
    and securityAlert = "Block mode uses non-cryptographic IV/Nonce source: $@"
  )
select cipherOperation, securityAlert, vulnerableSource, vulnerableSource.toString()
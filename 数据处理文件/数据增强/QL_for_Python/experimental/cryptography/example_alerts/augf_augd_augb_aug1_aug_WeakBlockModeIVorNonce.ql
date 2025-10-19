/**
 * @name Weak block mode IV or nonce
 * @description Detects insecure initialization vectors/nonces in block cipher operations.
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

// Identify block cipher operations with insecure IV/nonce configuration
from BlockMode cipherMode, string alertMessage, DataFlow::Node vulnerabilitySource
where
  // Skip Fernet encryption as it handles IV generation securely internally
  not cipherMode instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet
  and (
    // Scenario 1: IV/Nonce is missing
    not cipherMode.hasIVorNonce()
    and vulnerabilitySource = cipherMode
    and alertMessage = "Block mode is missing IV/Nonce initialization"
    or
    // Scenario 2: IV/Nonce comes from a non-cryptographic source
    cipherMode.hasIVorNonce()
    and not API::moduleImport("os").getMember("urandom").getACall() = cipherMode.getIVorNonce()
    and vulnerabilitySource = cipherMode.getIVorNonce()
    and alertMessage = "Block mode uses non-cryptographic IV/Nonce source: $@"
  )
select cipherMode, alertMessage, vulnerabilitySource, vulnerabilitySource.toString()
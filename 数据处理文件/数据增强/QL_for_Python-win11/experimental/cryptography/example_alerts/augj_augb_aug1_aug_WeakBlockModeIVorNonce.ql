/**
 * @name Weak block mode IV or nonce
 * @description Identifies block cipher operations using insecure initialization vectors or nonces.
 *              Flags IVs/nonces that are not generated using cryptographically secure methods (os.urandom).
 *
 *            IMPORTANT NOTES:
 *              1. Simplified detection approach: Any IV/nonce not derived from os.urandom is flagged
 *              2. Special cases handled:
 *                 - GCM mode: Requires unique nonce management (covered in a separate query)
 *                 - Fernet: Excluded from analysis (handles secure IV generation internally)
 *              3. Functions with dynamic mode/IV determination may produce false positives (manual review recommended)
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Locate block cipher operations with insecure IV/nonce configuration
from BlockMode blockCipherMode, string securityAlert, DataFlow::Node weaknessLocation
where
  // Exclude Fernet encryption (securely manages IV generation internally)
  not blockCipherMode instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet and
  (
    // Case 1: IV/Nonce is missing
    not blockCipherMode.hasIVorNonce() and
    weaknessLocation = blockCipherMode and
    securityAlert = "Block mode is missing IV/Nonce initialization"
    or
    // Case 2: IV/Nonce originates from non-cryptographic source
    blockCipherMode.hasIVorNonce() and
    not API::moduleImport("os").getMember("urandom").getACall() = blockCipherMode.getIVorNonce() and
    weaknessLocation = blockCipherMode.getIVorNonce() and
    securityAlert = "Block mode uses non-cryptographic IV/Nonce source: $@"
  )
select blockCipherMode, securityAlert, weaknessLocation, weaknessLocation.toString()
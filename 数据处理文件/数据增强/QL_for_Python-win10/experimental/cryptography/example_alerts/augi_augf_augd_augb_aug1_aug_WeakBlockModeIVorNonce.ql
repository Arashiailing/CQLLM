/**
 * @name Weak block mode IV or nonce
 * @description Identifies block cipher operations with insecure initialization vectors/nonces.
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

// Detect block cipher operations with insecure IV/nonce configuration
from BlockMode blockCipherMode, string securityAlert, DataFlow::Node weaknessSource
where
  // Skip Fernet encryption as it handles IV generation securely internally
  not blockCipherMode instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet
  and (
    // Case 1: IV/Nonce is missing
    (
      not blockCipherMode.hasIVorNonce()
      and weaknessSource = blockCipherMode
      and securityAlert = "Block mode is missing IV/Nonce initialization"
    )
    or
    // Case 2: IV/Nonce comes from a non-cryptographic source
    (
      blockCipherMode.hasIVorNonce()
      and not API::moduleImport("os").getMember("urandom").getACall() = blockCipherMode.getIVorNonce()
      and weaknessSource = blockCipherMode.getIVorNonce()
      and securityAlert = "Block mode uses non-cryptographic IV/Nonce source: $@"
    )
  )
select blockCipherMode, securityAlert, weaknessSource, weaknessSource.toString()
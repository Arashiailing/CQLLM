/**
 * @name Weak block mode IV or nonce
 * @description Identifies insecure initialization vectors/nonces in block cipher modes.
 *              Flags IVs/nonces not generated via cryptographically secure methods (os.urandom).
 *
 *            IMPORTANT NOTES:
 *              1. Simplified detection: Any IV/nonce not from os.urandom is flagged
 *              2. Special handling:
 *                 - GCM mode: Requires unique nonce management (handled separately)
 *                 - Fernet: Excluded (implements secure IV generation internally)
 *              3. Dynamic mode/IV determination may cause false positives (manual review needed)
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify block cipher operations with insecure IV/nonce configuration
from BlockMode blockCipherMode, string warningMessage, DataFlow::Node sourceNode
where
  // Exclude Fernet encryption (handles IV generation securely internally)
  not blockCipherMode instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet
  and (
    // Case 1: Missing IV/Nonce initialization
    not blockCipherMode.hasIVorNonce()
    and sourceNode = blockCipherMode
    and warningMessage = "Block mode is missing IV/Nonce initialization"
    or
    // Case 2: IV/Nonce from non-cryptographic source
    blockCipherMode.hasIVorNonce()
    and not API::moduleImport("os").getMember("urandom").getACall() = blockCipherMode.getIVorNonce()
    and sourceNode = blockCipherMode.getIVorNonce()
    and warningMessage = "Block mode uses non-cryptographic IV/Nonce source: $@"
  )
select blockCipherMode, warningMessage, sourceNode, sourceNode.toString()
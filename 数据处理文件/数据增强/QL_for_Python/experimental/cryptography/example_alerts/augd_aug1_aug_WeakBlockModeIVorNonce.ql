/**
 * @name Weak block mode IV or nonce
 * @description Detects insecure initialization vectors/nonces in block cipher modes.
 *              Identifies IVs/nonces not generated via cryptographically secure methods (os.urandom).
 *
 *            IMPORTANT NOTES:
 *              1. Simplified detection: Any IV/nonce not originating from os.urandom is flagged
 *              2. Special handling:
 *                 - GCM mode: Requires specific nonce management (addressed in separate query)
 *                 - Fernet: Excluded from detection (implements secure IV generation internally)
 *              3. Potential false positives: Functions that infer mode/IV may require manual review
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify block cipher operations with insecure IV/nonce configuration
from BlockMode blockModeOperation, string alertMessage, DataFlow::Node vulnerableNode
where
  // Filter out Fernet encryption (manages IV generation securely internally)
  not blockModeOperation instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet and
  (
    // Scenario 1: IV/Nonce is completely missing
    not blockModeOperation.hasIVorNonce() and
    vulnerableNode = blockModeOperation and
    alertMessage = "Block mode is missing IV/Nonce initialization"
    or
    // Scenario 2: IV/Nonce is present but from insecure source (non-os.urandom)
    blockModeOperation.hasIVorNonce() and
    not API::moduleImport("os").getMember("urandom").getACall() = blockModeOperation.getIVorNonce() and
    vulnerableNode = blockModeOperation.getIVorNonce() and
    alertMessage = "Block mode uses non-cryptographic IV/Nonce source: $@"
  )
select blockModeOperation, alertMessage, vulnerableNode, vulnerableNode.toString()
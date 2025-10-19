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

// Identify block cipher operations with insecure IV/nonce configuration
from BlockMode cipherModeOperation, string issueDescription, DataFlow::Node vulnerableNode
where
  // Exclude Fernet encryption as it handles IV generation internally
  not cipherModeOperation instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet
  and
  (
    // Scenario 1: Block cipher mode lacks IV/Nonce initialization
    not cipherModeOperation.hasIVorNonce()
    and
    vulnerableNode = cipherModeOperation
    and
    issueDescription = "Block mode is missing IV/Nonce initialization"
    or
    // Scenario 2: Block cipher mode uses IV/Nonce from non-cryptographic source
    cipherModeOperation.hasIVorNonce()
    and
    not API::moduleImport("os").getMember("urandom").getACall() = cipherModeOperation.getIVorNonce()
    and
    vulnerableNode = cipherModeOperation.getIVorNonce()
    and
    issueDescription = "Block mode uses non-cryptographic IV/Nonce source: $@"
  )
select cipherModeOperation, issueDescription, vulnerableNode, vulnerableNode.toString()
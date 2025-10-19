/**
 * @name Weak block mode IV or nonce
 * @description Detects insecure initialization vectors/nonces in block cipher modes.
 *              Flags IVs/nonces not generated using cryptographically secure methods (os.urandom).
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
from BlockMode blockModeOp, string issueMsg, DataFlow::Node vulnNode
where
  // Exclude Fernet encryption (handles IV generation internally)
  not blockModeOp instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet
  and
  (
    // Case 1: Block mode lacks IV/Nonce initialization
    (
      not blockModeOp.hasIVorNonce()
      and
      vulnNode = blockModeOp
      and
      issueMsg = "Block mode is missing IV/Nonce initialization"
    )
    or
    // Case 2: Block mode uses IV/Nonce from non-cryptographic source
    (
      blockModeOp.hasIVorNonce()
      and
      not API::moduleImport("os").getMember("urandom").getACall() = blockModeOp.getIVorNonce()
      and
      vulnNode = blockModeOp.getIVorNonce()
      and
      issueMsg = "Block mode uses non-cryptographic IV/Nonce source: $@"
    )
  )
select blockModeOp, issueMsg, vulnNode, vulnNode.toString()
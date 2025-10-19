/**
 * @name Weak block mode IV or nonce
 * @description Detects block cipher operations that use insecure initialization vectors or nonces.
 *              The query identifies IVs/nonces not generated through cryptographically secure methods (os.urandom).
 *
 *            NOTE: 
 *              1. Simplified detection: All IV/nonce sources are flagged except os.urandom
 *              2. Special cases:
 *                 - GCM mode: Requires unique nonce handling (addressed in a separate query)
 *                 - Fernet: Excluded from analysis (manages secure IV generation internally)
 *              3. Functions that infer mode/IV might generate false positives (manual review recommended)
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify vulnerable block cipher operations
from BlockMode blockCipherOp, string alertMessage, DataFlow::Node weakSourceNode
where
  // Exclude Fernet (secure IV generation handled internally)
  not blockCipherOp instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet and
  (
    // Case 1: Missing IV/Nonce initialization
    not blockCipherOp.hasIVorNonce() and
    weakSourceNode = blockCipherOp and
    alertMessage = "Block mode is missing IV/Nonce initialization"
    or
    // Case 2: Non-cryptographic IV/Nonce source
    blockCipherOp.hasIVorNonce() and
    not API::moduleImport("os").getMember("urandom").getACall() = blockCipherOp.getIVorNonce() and
    weakSourceNode = blockCipherOp.getIVorNonce() and
    alertMessage = "Block mode uses non-cryptographic IV/Nonce source: $@"
  )
select blockCipherOp, alertMessage, weakSourceNode, weakSourceNode.toString()
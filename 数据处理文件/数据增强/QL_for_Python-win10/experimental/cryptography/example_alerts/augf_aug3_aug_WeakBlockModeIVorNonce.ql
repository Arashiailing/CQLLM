/**
 * @name Weak block mode IV or nonce
 * @description Detects block cipher operations that use insecure initialization vectors or nonces.
 *              The query flags IVs/nonces that are not generated using cryptographically secure
 *              methods like os.urandom.
 *              
 *            NOTE:
 *              1. Simplified approach: All IV/nonce sources are flagged except os.urandom
 *              2. Special cases:
 *                 - GCM mode: Requires separate nonce handling (addressed in a different query)
 *                 - Fernet: Excluded from analysis (handles secure IV generation internally)
 *              3. Functions that infer mode/IV might generate false positives (manual review advised)
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify block cipher operations with weak IV/nonce handling
from BlockMode blockCipherOp, string alertMessage, DataFlow::Node weakSourceNode
where
  // Exclude Fernet as it handles secure IV generation internally
  not blockCipherOp instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet and
  (
    // Case 1: Block cipher operation lacks IV/Nonce initialization
    if not blockCipherOp.hasIVorNonce()
    then (
      weakSourceNode = blockCipherOp and
      alertMessage = "Block mode is missing IV/Nonce initialization"
    )
    // Case 2: Block cipher operation uses non-cryptographic IV/Nonce source
    else (
      not API::moduleImport("os").getMember("urandom").getACall() = blockCipherOp.getIVorNonce() and
      weakSourceNode = blockCipherOp.getIVorNonce() and
      alertMessage = "Block mode uses non-cryptographic IV/Nonce source: $@"
    )
  )
select blockCipherOp, alertMessage, weakSourceNode, weakSourceNode.toString()
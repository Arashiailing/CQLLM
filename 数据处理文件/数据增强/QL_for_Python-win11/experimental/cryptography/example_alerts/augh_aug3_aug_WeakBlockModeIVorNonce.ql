/**
 * @name Weak block mode IV or nonce
 * @description Detects block cipher operations using insecure initialization vectors/nonces.
 *              This query identifies IVs/nonces not generated via cryptographically secure
 *              methods (specifically os.urandom).
 *
 *            NOTE: 
 *              1. Simplified approach: Flags all IV/nonce sources except os.urandom
 *              2. Special cases:
 *                 - GCM mode: Requires separate nonce handling (covered in distinct query)
 *                 - Fernet: Excluded (implements secure IV generation internally)
 *              3. Functions inferring mode/IV may produce false positives (manual review needed)
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Locate block cipher operations with weak IV/nonce handling
from BlockMode cipherOp, string diagnosticMsg, DataFlow::Node insecureSource
where
  // Exclude Fernet (handles IV generation securely internally)
  not cipherOp instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet and
  (
    // Scenario 1: IV/Nonce initialization is missing
    if not cipherOp.hasIVorNonce()
    then (
      insecureSource = cipherOp and
      diagnosticMsg = "Block mode is missing IV/Nonce initialization"
    )
    // Scenario 2: IV/Nonce comes from non-cryptographic source
    else (
      not API::moduleImport("os").getMember("urandom").getACall() = cipherOp.getIVorNonce() and
      insecureSource = cipherOp.getIVorNonce() and
      diagnosticMsg = "Block mode uses non-cryptographic IV/Nonce source: $@"
    )
  )
select cipherOp, diagnosticMsg, insecureSource, insecureSource.toString()
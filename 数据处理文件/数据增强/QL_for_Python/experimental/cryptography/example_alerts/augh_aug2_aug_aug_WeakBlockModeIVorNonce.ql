/**
 * @name Weak block mode IV or nonce
 * @description Detects insecure initialization vectors (IVs) or nonces in block cipher operations.
 *              Flags cases where IVs/nonces are either missing or not generated using os.urandom.
 *              Excludes Fernet as it handles IV generation internally. Complex cases may require
 *              manual verification.
 *
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags security
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify block cipher operations with weak IV/nonce configurations
from BlockMode blockCipherOp, string alertMsg, DataFlow::Node vulnerableSource
where
  // Exclude Fernet (handles IV generation internally)
  not blockCipherOp instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet and
  (
    // Check for missing IV/nonce OR non-os.urandom source
    not blockCipherOp.hasIVorNonce() or
    not API::moduleImport("os").getMember("urandom").getACall() = blockCipherOp.getIVorNonce()
  ) and
  // Determine the vulnerable source based on IV/nonce presence
  (
    // Case 1: Missing IV/nonce - flag the entire operation
    if not blockCipherOp.hasIVorNonce()
    then vulnerableSource = blockCipherOp
    // Case 2: IV/nonce from insecure source - flag the IV/nonce node
    else vulnerableSource = blockCipherOp.getIVorNonce()
  ) and
  // Set unified error message
  alertMsg = "Block mode is not using an accepted IV/Nonce initialization: $@"
select blockCipherOp, alertMsg, vulnerableSource, vulnerableSource.toString()
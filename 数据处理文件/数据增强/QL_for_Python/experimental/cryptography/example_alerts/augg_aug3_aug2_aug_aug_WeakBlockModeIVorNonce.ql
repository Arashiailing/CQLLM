/**
 * @name Weak block mode IV or nonce
 * @description Identifies insecure initialization vectors (IVs) or nonces in block cipher operations.
 *              Flags cases where IVs/nonces are either missing or not generated using os.urandom.
 *              Fernet is excluded as it handles IV generation internally. Complex cases may require
 *              manual review.
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

// Identify block cipher operations with vulnerable IV/nonce configurations
from BlockMode blockCipherOp, string alertMsg, DataFlow::Node vulnSource
where
  // Exclude Fernet (manages IV generation internally)
  not blockCipherOp instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet and
  (
    // Check for missing IV/nonce OR non-os.urandom source
    not blockCipherOp.hasIVorNonce() or
    not API::moduleImport("os").getMember("urandom").getACall() = blockCipherOp.getIVorNonce()
  ) and
  // Determine vulnerability source and contextual message
  (
    // Case 1: Missing IV/nonce
    if not blockCipherOp.hasIVorNonce()
    then (
      vulnSource = blockCipherOp and 
      alertMsg = "Block mode is missing IV/Nonce initialization."
    )
    // Case 2: IV/nonce from insecure source
    else (
      vulnSource = blockCipherOp.getIVorNonce()
    )
  ) and
  // Standardize final alert message
  alertMsg = "Block mode is not using an accepted IV/Nonce initialization: $@"
select blockCipherOp, alertMsg, vulnSource, vulnSource.toString()
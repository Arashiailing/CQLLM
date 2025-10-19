/**
 * @name Weak block mode IV or nonce
 * @description Detects insecure initialization vectors (IVs) or nonces in block cipher operations.
 *              This query flags instances where IVs/nonces are either absent or not generated
 *              using os.urandom. Fernet is exempted since it handles IV generation internally.
 *              Note: Complex scenarios may necessitate manual verification.
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
from BlockMode blockCipherOperation, string securityAlert, DataFlow::Node vulnerabilityOrigin
where
  // Exclude Fernet as it manages IV generation internally
  not blockCipherOperation instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet and
  (
    // Check for missing IV/nonce OR non-os.urandom source
    not blockCipherOperation.hasIVorNonce() or
    not API::moduleImport("os").getMember("urandom").getACall() = blockCipherOperation.getIVorNonce()
  ) and
  // Determine vulnerability source and contextual message
  (
    // Case 1: Missing IV/nonce
    if not blockCipherOperation.hasIVorNonce()
    then (
      vulnerabilityOrigin = blockCipherOperation and 
      securityAlert = "Block mode is missing IV/Nonce initialization."
    )
    // Case 2: IV/nonce from insecure source
    else (
      vulnerabilityOrigin = blockCipherOperation.getIVorNonce()
    )
  ) and
  // Standardize final alert message
  securityAlert = "Block mode is not using an accepted IV/Nonce initialization: $@"
select blockCipherOperation, securityAlert, vulnerabilityOrigin, vulnerabilityOrigin.toString()
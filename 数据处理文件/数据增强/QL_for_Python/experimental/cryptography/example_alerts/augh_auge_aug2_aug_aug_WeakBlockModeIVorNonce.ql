/**
 * @name Vulnerable block mode IV or nonce usage
 * @description Detects insecure initialization vectors (IVs) or nonces in block cipher implementations.
 *              This query highlights instances where IVs/nonces are either absent or not derived from
 *              cryptographically secure os.urandom. Fernet is exempt since it manages IV generation
 *              internally. Certain sophisticated scenarios might necessitate manual verification.
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

// Identify block cipher operations with insecure IV/nonce configurations
from BlockMode blockCipherOp, string securityAlert, DataFlow::Node vulnerableIVSource
where
  // Exclude Fernet as it manages IV generation internally
  not blockCipherOp instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet and
  (
    // Detect scenarios with missing IV/nonce or IV/nonce not from os.urandom
    not blockCipherOp.hasIVorNonce() or
    not API::moduleImport("os").getMember("urandom").getACall() = blockCipherOp.getIVorNonce()
  ) and
  // Determine the vulnerable source and security alert based on IV/nonce presence
  (
    if not blockCipherOp.hasIVorNonce()
    then (
      // Scenario where IV/nonce is absent
      vulnerableIVSource = blockCipherOp and 
      securityAlert = "Block mode is missing IV/Nonce initialization."
    )
    else (
      // Scenario where IV/nonce originates from an untrusted source
      vulnerableIVSource = blockCipherOp.getIVorNonce()
    )
  ) and
  // Construct the final security alert message
  securityAlert = "Block mode is not using an accepted IV/Nonce initialization: $@"
select blockCipherOp, securityAlert, vulnerableIVSource, vulnerableIVSource.toString()
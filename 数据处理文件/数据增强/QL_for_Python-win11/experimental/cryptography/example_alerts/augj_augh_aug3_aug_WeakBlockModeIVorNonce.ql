/**
 * @name Weak block mode IV or nonce
 * @description Identifies block cipher operations that utilize insecure initialization vectors/nonces.
 *              This query specifically flags IVs/nonces not generated through cryptographically
 *              secure methods (with emphasis on os.urandom).
 *
 *            NOTE: 
 *              1. Simplified approach: All IV/nonce sources are flagged except os.urandom
 *              2. Special cases:
 *                 - GCM mode: Requires unique nonce handling (addressed in a separate query)
 *                 - Fernet: Excluded (manages secure IV generation internally)
 *              3. Functions that infer mode/IV might yield false positives (manual verification advised)
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify block cipher operations with weak IV/nonce handling
from BlockMode blockCipherOperation, string alertMessage, DataFlow::Node vulnerableSource
where
  // Exclude Fernet as it handles IV generation securely internally
  not blockCipherOperation instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet
  
  // Scenario 1: IV/Nonce initialization is missing
  and (
    (
      not blockCipherOperation.hasIVorNonce() and
      vulnerableSource = blockCipherOperation and
      alertMessage = "Block mode is missing IV/Nonce initialization"
    )
    
    // Scenario 2: IV/Nonce originates from a non-cryptographic source
    or (
      blockCipherOperation.hasIVorNonce() and
      not API::moduleImport("os").getMember("urandom").getACall() = blockCipherOperation.getIVorNonce() and
      vulnerableSource = blockCipherOperation.getIVorNonce() and
      alertMessage = "Block mode uses non-cryptographic IV/Nonce source: $@"
    )
  )
  
select blockCipherOperation, alertMessage, vulnerableSource, vulnerableSource.toString()
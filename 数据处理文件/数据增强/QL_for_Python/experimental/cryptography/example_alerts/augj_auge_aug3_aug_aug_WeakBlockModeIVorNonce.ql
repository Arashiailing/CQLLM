/**
 * @name Weak block mode IV or nonce
 * @description Identifies insecure initialization vector (IV) or nonce usage in block cipher operations.
 *              This query detects scenarios where IVs/nonces are either absent or not generated
 *              using cryptographically secure random functions like os.urandom.
 *              
 *              Fernet encryption is exempted from this analysis since it automatically handles
 *              IV generation using secure methods. Complex cryptographic implementations may
 *              require manual review by security professionals.
 *
 *            NOTE: This query alerts on any IV/nonce that doesn't originate from os.urandom
 *                  or has an indeterminate source. Advanced nonce management patterns (e.g.,
 *                  in GCM mode) should be manually verified. Functions that derive both mode
 *                  and IV might produce false positives that can be suppressed as needed.
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify block cipher modes with vulnerable IV/nonce configurations
from BlockMode blockCipherMode, string alertMessage, DataFlow::Node vulnerabilitySource
where
  // Exclude Fernet encryption as it manages IV generation internally
  not blockCipherMode instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet and
  (
    // Detect either missing IV/nonce OR IV/nonce from insecure source
    not blockCipherMode.hasIVorNonce() or
    not API::moduleImport("os").getMember("urandom").getACall() = blockCipherMode.getIVorNonce()
  ) and
  // Generate appropriate alert details based on IV/nonce status
  (
    // Handle case where IV/nonce is completely missing
    if not blockCipherMode.hasIVorNonce()
    then (
      vulnerabilitySource = blockCipherMode and 
      alertMessage = "Block mode is missing IV/Nonce initialization."
    )
    // Handle case where IV/nonce exists but from untrusted source
    else (
      vulnerabilitySource = blockCipherMode.getIVorNonce() and
      alertMessage = "Block mode is not using an accepted IV/Nonce initialization: $@"
    )
  )
select blockCipherMode, alertMessage, vulnerabilitySource, vulnerabilitySource.toString()
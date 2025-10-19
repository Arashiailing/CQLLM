/**
 * @name Weak block mode IV or nonce
 * @description Identifies block cipher operations utilizing insecure initialization vectors or nonces.
 *              This query flags IVs/nonces not generated via cryptographically secure methods (specifically os.urandom).
 *
 *            NOTE: 
 *              1. Simplified detection approach: All IV/nonce sources are flagged except os.urandom
 *              2. Special handling:
 *                 - GCM mode: Requires unique nonce management (covered in a separate query)
 *                 - Fernet: Excluded from analysis (handles secure IV generation internally)
 *              3. Functions that infer mode/IV may produce false positives (manual verification advised)
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify block cipher operations with potential IV/nonce vulnerabilities
from BlockMode cipherOperation, string vulnerabilityMessage, DataFlow::Node vulnerableSource
where
  // Exclude Fernet as it manages secure IV generation internally
  not cipherOperation instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet and
  (
    // Scenario 1: Cipher operation lacks IV/Nonce initialization
    (
      not cipherOperation.hasIVorNonce() and
      vulnerableSource = cipherOperation and
      vulnerabilityMessage = "Block mode is missing IV/Nonce initialization"
    )
    or
    // Scenario 2: Cipher operation uses non-cryptographic IV/Nonce source
    (
      cipherOperation.hasIVorNonce() and
      not API::moduleImport("os").getMember("urandom").getACall() = cipherOperation.getIVorNonce() and
      vulnerableSource = cipherOperation.getIVorNonce() and
      vulnerabilityMessage = "Block mode uses non-cryptographic IV/Nonce source: $@"
    )
  )
select cipherOperation, vulnerabilityMessage, vulnerableSource, vulnerableSource.toString()
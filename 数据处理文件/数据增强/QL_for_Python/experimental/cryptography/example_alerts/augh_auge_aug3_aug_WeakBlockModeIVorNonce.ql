/**
 * @name Weak block mode IV or nonce
 * @description Identifies block cipher operations utilizing insecure initialization vectors or nonces.
 *              This query flags IVs/nonces that are not generated using cryptographically secure methods (specifically os.urandom).
 *
 *            IMPORTANT NOTES:
 *              1. Detection approach: The query treats all IV/nonce sources as potentially insecure except os.urandom
 *              2. Special handling:
 *                 - GCM mode: Requires unique nonce management (covered by a separate dedicated query)
 *                 - Fernet: Excluded from this analysis (implements secure IV generation internally)
 *              3. Potential false positives: Functions that infer mode/IV may trigger alerts (manual verification advised)
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify block cipher operations with vulnerable IV/nonce handling
from BlockMode blockCipherOperation, string securityAlert, DataFlow::Node vulnerableSource
where
  // Skip Fernet encryption as it handles IV generation securely internally
  not blockCipherOperation instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet
  and
  (
    // Scenario 1: Block cipher operation completely lacks IV/Nonce initialization
    not blockCipherOperation.hasIVorNonce()
    and
    vulnerableSource = blockCipherOperation
    and
    securityAlert = "Block mode is missing IV/Nonce initialization"
    or
    // Scenario 2: Block cipher uses IV/Nonce from non-cryptographic source
    blockCipherOperation.hasIVorNonce()
    and
    not API::moduleImport("os").getMember("urandom").getACall() = blockCipherOperation.getIVorNonce()
    and
    vulnerableSource = blockCipherOperation.getIVorNonce()
    and
    securityAlert = "Block mode uses non-cryptographic IV/Nonce source: $@"
  )
select blockCipherOperation, securityAlert, vulnerableSource, vulnerableSource.toString()
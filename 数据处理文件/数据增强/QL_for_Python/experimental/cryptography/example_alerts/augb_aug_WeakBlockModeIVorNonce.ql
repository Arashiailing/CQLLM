/**
 * @name Weak block mode IV or nonce
 * @description Identifies vulnerable initialization vectors or nonces in block cipher modes.
 *              Highlights IVs/nonces not generated via cryptographically secure methods (os.urandom).
 *
 *            IMPORTANT NOTES:
 *              1. Detection approach: Flags any IV/nonce not originating from os.urandom
 *              2. Exclusions:
 *                 - GCM mode: Requires unique nonce handling (addressed in separate analysis)
 *                 - Fernet: Excluded from detection (implements secure IV generation internally)
 *              3. Potential false positives: Functions that infer mode/IV may require manual review
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Locate block cipher operations with insecure IV/nonce configuration
from BlockMode blockCipherMode, string securityAlert, DataFlow::Node weakSourceNode
where
  // Skip Fernet encryption (manages IV generation securely internally)
  not blockCipherMode instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet and
  (
    // Scenario 1: Operation lacks IV/Nonce initialization
    if not blockCipherMode.hasIVorNonce()
    then (
      weakSourceNode = blockCipherMode and
      securityAlert = "Block mode operation missing IV/Nonce initialization"
    )
    // Scenario 2: IV/Nonce derived from non-cryptographic source
    else (
      not API::moduleImport("os").getMember("urandom").getACall() = blockCipherMode.getIVorNonce() and
      weakSourceNode = blockCipherMode.getIVorNonce() and
      securityAlert = "Block mode using insecure IV/Nonce source: $@"
    )
  )
select blockCipherMode, securityAlert, weakSourceNode, weakSourceNode.toString()
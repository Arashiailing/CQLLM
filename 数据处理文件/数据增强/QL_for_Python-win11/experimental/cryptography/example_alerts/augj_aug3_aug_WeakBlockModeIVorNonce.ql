/**
 * @name Weak block mode IV or nonce
 * @description Detects block cipher operations with insecure initialization vectors/nonces.
 *              The query identifies IVs/nonces that are not generated using cryptographically
 *              secure methods, specifically os.urandom.
 *
 *            IMPORTANT NOTES:
 *              1. Detection Approach: This is a simplified check that flags any IV/nonce source
 *                 other than os.urandom as potentially vulnerable.
 *              2. Exclusions:
 *                 - GCM mode: Requires special nonce handling (addressed in a separate query)
 *                 - Fernet: Excluded from analysis (implements secure IV generation internally)
 *              3. False Positives: Functions that dynamically determine mode/IV may trigger
 *                 false positives and require manual review.
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify block cipher operations with weak IV/nonce handling
from BlockMode blockCipherOperation, string vulnerabilityMessage, DataFlow::Node vulnerableSourceNode
where
  // Skip Fernet as it handles IV generation securely internally
  not blockCipherOperation instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet and
  (
    // Check for missing IV/nonce initialization
    not blockCipherOperation.hasIVorNonce() and
    (
      vulnerableSourceNode = blockCipherOperation and
      vulnerabilityMessage = "Block mode is missing IV/Nonce initialization"
    )
    or
    // Check for non-cryptographic IV/nonce sources
    blockCipherOperation.hasIVorNonce() and
    not API::moduleImport("os").getMember("urandom").getACall() = blockCipherOperation.getIVorNonce() and
    (
      vulnerableSourceNode = blockCipherOperation.getIVorNonce() and
      vulnerabilityMessage = "Block mode uses non-cryptographic IV/Nonce source: $@"
    )
  )
select blockCipherOperation, vulnerabilityMessage, vulnerableSourceNode, vulnerableSourceNode.toString()
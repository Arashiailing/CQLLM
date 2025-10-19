/**
 * @name Weak block mode IV or nonce
 * @description Detects insecure initialization vectors/nonces in block cipher modes.
 *              Highlights IVs/nonces that are not generated using cryptographically secure methods (os.urandom).
 *
 *            IMPORTANT: 
 *              1. Simplified detection: Any IV/nonce not originating from os.urandom is flagged
 *              2. Exceptions:
 *                 - GCM mode: Requires unique nonce handling (addressed in a separate query)
 *                 - Fernet: Excluded by design (utilizes os.urandom internally)
 *              3. Functions that infer mode/IV might yield false positives (manual review needed)
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Find block cipher operations with insecure IV/nonce configuration
from BlockMode blockCipherOperation, string securityIssue, DataFlow::Node insecureNode
where
  // Exclude Fernet encryption as it handles IV generation internally
  not blockCipherOperation instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet
  and
  (
    // Case 1: Block cipher mode lacks IV/Nonce initialization
    not blockCipherOperation.hasIVorNonce()
    and
    insecureNode = blockCipherOperation
    and
    securityIssue = "Block mode is missing IV/Nonce initialization"
    or
    // Case 2: Block cipher mode uses IV/Nonce from non-cryptographic source
    blockCipherOperation.hasIVorNonce()
    and
    not API::moduleImport("os").getMember("urandom").getACall() = blockCipherOperation.getIVorNonce()
    and
    insecureNode = blockCipherOperation.getIVorNonce()
    and
    securityIssue = "Block mode uses non-cryptographic IV/Nonce source: $@"
  )
select blockCipherOperation, securityIssue, insecureNode, insecureNode.toString()
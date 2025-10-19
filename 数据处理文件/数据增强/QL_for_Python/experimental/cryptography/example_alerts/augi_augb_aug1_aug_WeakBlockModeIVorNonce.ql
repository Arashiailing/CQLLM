/**
 * @name Weak block mode IV or nonce
 * @description Identifies insecure initialization vectors/nonces in block cipher operations.
 *              Flags IVs/nonces that are not generated using cryptographically secure methods (os.urandom).
 *
 *            KEY CONSIDERATIONS:
 *              1. Detection approach: Any IV/nonce not derived from os.urandom is considered vulnerable
 *              2. Exception cases:
 *                 - GCM mode: Requires special nonce handling (covered in dedicated query)
 *                 - Fernet: Excluded from scope (handles IV generation securely internally)
 *              3. Dynamic mode/IV selection may cause false positives (requires manual verification)
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Detect block cipher operations with insecure IV/nonce configuration
from BlockMode blockCipherOperation, string securityAlert, DataFlow::Node insecureFlowNode
where
  // Exclude Fernet encryption (implements secure IV generation internally)
  not blockCipherOperation instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet
  and
  (
    // Case 1: Missing IV/Nonce initialization
    not blockCipherOperation.hasIVorNonce()
    and
    insecureFlowNode = blockCipherOperation
    and
    securityAlert = "Block mode is missing IV/Nonce initialization"
    or
    // Case 2: IV/Nonce from non-cryptographic source
    blockCipherOperation.hasIVorNonce()
    and
    not API::moduleImport("os").getMember("urandom").getACall() = blockCipherOperation.getIVorNonce()
    and
    insecureFlowNode = blockCipherOperation.getIVorNonce()
    and
    securityAlert = "Block mode uses non-cryptographic IV/Nonce source: $@"
  )
select blockCipherOperation, securityAlert, insecureFlowNode, insecureFlowNode.toString()
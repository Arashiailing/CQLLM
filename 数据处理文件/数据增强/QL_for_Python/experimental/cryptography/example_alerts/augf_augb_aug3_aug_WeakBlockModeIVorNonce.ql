/**
 * @name Weak block mode IV or nonce
 * @description Detects block cipher operations using insecure initialization vectors/nonces
 *              that are not generated through cryptographically secure methods (os.urandom).
 *
 *            NOTE: 
 *              1. Simplified detection: Flags all IV/nonce sources except os.urandom
 *              2. Special handling:
 *                 - GCM mode: Requires separate nonce analysis (covered in separate query)
 *                 - Fernet: Excluded from analysis (secure IV generation implemented internally)
 *              3. Functions that infer mode/IV might generate false positives (manual review advised)
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify vulnerable block cipher operations
from BlockMode cipherOperation, string warningMessage, DataFlow::Node originNode
where
  // Exclude Fernet due to its internal secure IV generation
  not cipherOperation instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet
  and
  (
    // Case 1: Block cipher operation lacks IV/Nonce initialization
    (not cipherOperation.hasIVorNonce() and
     originNode = cipherOperation and
     warningMessage = "Block mode is missing IV/Nonce initialization")
    or
    // Case 2: IV/Nonce source is not cryptographically secure
    (cipherOperation.hasIVorNonce() and
     // Verify that IV/Nonce is not generated using os.urandom
     not API::moduleImport("os").getMember("urandom").getACall() = cipherOperation.getIVorNonce() and
     originNode = cipherOperation.getIVorNonce() and
     warningMessage = "Block mode uses non-cryptographic IV/Nonce source: $@")
  )
select cipherOperation, warningMessage, originNode, originNode.toString()
/**
 * @name Weak block mode IV or nonce
 * @description Identifies vulnerable initialization vectors/nonces in block cipher operations
 *              where IVs/nonces are not generated via cryptographically secure methods (os.urandom).
 *
 *            NOTE: 
 *              1. Simplified approach: Flags all IV/nonce sources except os.urandom
 *              2. Special cases:
 *                 - GCM mode: Requires separate nonce handling (covered in distinct query)
 *                 - Fernet: Excluded (implements secure IV generation internally)
 *              3. Functions inferring mode/IV may produce false positives (user review needed)
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify vulnerable block cipher operations
from BlockMode blockCipherOperation, string alertMessage, DataFlow::Node sourceNode
where
  // Exclude Fernet (secure IV generation handled internally)
  not blockCipherOperation instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet
  and
  (
    // Case 1: Missing IV/Nonce initialization
    (not blockCipherOperation.hasIVorNonce() and
     sourceNode = blockCipherOperation and
     alertMessage = "Block mode is missing IV/Nonce initialization")
    or
    // Case 2: Non-cryptographic IV/Nonce source
    (blockCipherOperation.hasIVorNonce() and
     // Check if IV/Nonce is not generated via os.urandom
     not API::moduleImport("os").getMember("urandom").getACall() = blockCipherOperation.getIVorNonce() and
     sourceNode = blockCipherOperation.getIVorNonce() and
     alertMessage = "Block mode uses non-cryptographic IV/Nonce source: $@")
  )
select blockCipherOperation, alertMessage, sourceNode, sourceNode.toString()
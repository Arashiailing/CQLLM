/**
 * @name Weak block mode IV or nonce
 * @description Detects block cipher operations using insecure initialization vectors or nonces.
 *              The query identifies IVs/nonces not generated via cryptographically secure methods (os.urandom).
 *
 *            NOTE: 
 *              1. Simplified approach: Flags all IV/nonce sources except os.urandom
 *              2. Special cases:
 *                 - GCM mode: Requires separate nonce handling (covered in distinct query)
 *                 - Fernet: Excluded (implements secure IV generation internally)
 *              3. Functions inferring mode/IV may produce false positives (manual review needed)
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify block cipher operations with vulnerable IV/nonce usage
from BlockMode cryptoOperation, string diagnosticMessage, DataFlow::Node ivOriginNode
where
  // Exclude Fernet (handles IV generation securely internally)
  not cryptoOperation instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet
  and
  (
    // Case 1: IV/Nonce initialization is missing
    (not cryptoOperation.hasIVorNonce() and
     ivOriginNode = cryptoOperation and
     diagnosticMessage = "Block mode operation lacks IV/Nonce initialization")
    or
    // Case 2: IV/Nonce originates from non-cryptographic source
    (cryptoOperation.hasIVorNonce() and
     // Verify IV/Nonce is not generated via os.urandom
     not API::moduleImport("os").getMember("urandom").getACall() = cryptoOperation.getIVorNonce() and
     ivOriginNode = cryptoOperation.getIVorNonce() and
     diagnosticMessage = "Block mode uses non-cryptographic IV/Nonce source: $@")
  )
select cryptoOperation, diagnosticMessage, ivOriginNode, ivOriginNode.toString()
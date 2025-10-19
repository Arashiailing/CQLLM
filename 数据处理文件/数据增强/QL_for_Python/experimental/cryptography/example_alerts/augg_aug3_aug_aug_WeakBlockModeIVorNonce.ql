/**
 * @name Weak block mode IV or nonce
 * @description Identifies vulnerable initialization vector (IV) or nonce usage in block cipher operations.
 *              Flags cases where IVs/nonces are missing or not generated using os.urandom.
 *              Fernet is excluded as it manages IV internally. Complex cases require manual review.
 *
 *            NOTE: This query highlights any IV/nonce not derived from os.urandom or with ambiguous origins.
 *                  Advanced patterns (e.g., GCM nonce usage) necessitate expert evaluation. Functions that
 *                  determine both mode and IV may yield false positives (mitigated via suppression).
 *                  Fernet is intentionally excluded due to its built-in os.urandom implementation.
 * @id py/weak-block-mode-iv-or-nonce
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Detect block cipher modes with insecure IV/nonce configurations
from BlockMode cipherMode, string diagnosticMessage, DataFlow::Node sourceNode
where
  // Skip Fernet as it internally manages IV generation
  not cipherMode instanceof CryptographyModule::Encryption::SymmetricEncryption::Fernet::CryptographyFernet and
  (
    // Identify missing IV/nonce OR non-os.urandom source
    not cipherMode.hasIVorNonce() or
    not API::moduleImport("os").getMember("urandom").getACall() = cipherMode.getIVorNonce()
  ) and
  // Set diagnostic details based on IV/nonce availability
  (
    // Process scenario with absent IV/nonce
    if not cipherMode.hasIVorNonce()
    then (
      sourceNode = cipherMode and 
      diagnosticMessage = "Block mode is missing IV/Nonce initialization."
    )
    // Process scenario with insecure IV/nonce source
    else (
      sourceNode = cipherMode.getIVorNonce()
    )
  ) and
  // Construct final diagnostic message including source reference
  diagnosticMessage = "Block mode is not using an accepted IV/Nonce initialization: $@"
select cipherMode, diagnosticMessage, sourceNode, sourceNode.toString()
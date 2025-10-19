/**
 * @name Initialization Vector (IV) or nonces
 * @description Identifies potential sources of initialization vectors (IV) or nonce values 
 *              utilized in block cipher operations across supported cryptographic libraries.
 *              This query helps in identifying potential cryptographic weaknesses related to
 *              IV/nonce management in block cipher modes of operation.
 * @kind problem
 * @id py/quantum-readiness/cbom/iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify all expressions providing initialization vectors or nonces
// for block cipher encryption modes in cryptographic operations
from BlockMode cipherOperationMode, Expr ivNonceSource
where ivNonceSource = cipherOperationMode.getIVorNonce().asExpr()
select ivNonceSource, "Block mode IV/Nonce source"
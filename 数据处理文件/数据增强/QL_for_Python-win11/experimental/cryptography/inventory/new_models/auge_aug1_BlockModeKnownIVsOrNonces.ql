/**
 * @name Initialization Vector (IV) or Nonce Sources
 * @description Detects potential initialization vectors (IV) or nonce values 
 *              used in block cipher operations across supported cryptographic libraries.
 *              This analysis identifies cryptographic components potentially vulnerable 
 *              to quantum computing attacks.
 * @kind problem
 * @id py/quantum-readiness/cbom/iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify cryptographic initialization vectors or nonces
// originating from block cipher modes of operation
from BlockMode cipherMode
select cipherMode.getIVorNonce().asExpr(), "Block mode IV/Nonce source"
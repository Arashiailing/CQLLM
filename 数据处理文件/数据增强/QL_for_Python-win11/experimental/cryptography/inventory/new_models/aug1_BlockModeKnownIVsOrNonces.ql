/**
 * @name Initialization Vector (IV) or nonces
 * @description Identifies potential sources of initialization vectors (IV) or nonce values
 *              utilized in block cipher operations within supported cryptographic libraries.
 *              This analysis helps identify cryptographic components that may be affected
 *              by quantum computing attacks.
 * @kind problem
 * @id py/quantum-readiness/cbom/iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Define the source of cryptographic initialization vectors or nonces
// from block cipher modes of operation
from BlockMode blockCipherMode
select blockCipherMode.getIVorNonce().asExpr(), "Block mode IV/Nonce source"
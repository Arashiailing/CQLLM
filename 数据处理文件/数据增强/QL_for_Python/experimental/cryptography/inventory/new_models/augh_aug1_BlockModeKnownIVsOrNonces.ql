/**
 * @name Initialization Vector (IV) or Nonce Sources
 * @description Detects potential sources of initialization vectors (IV) or nonce values
 *              used in block cipher operations across supported cryptographic libraries.
 *              This query helps identify cryptographic components that could be vulnerable
 *              to quantum computing attacks by revealing where these critical values originate.
 * @kind problem
 * @id py/quantum-readiness/cbom/iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify cryptographic initialization vectors or nonces
// derived from block cipher modes of operation
from BlockMode cryptoBlockMode
select cryptoBlockMode.getIVorNonce().asExpr(), "Block mode IV/Nonce source"
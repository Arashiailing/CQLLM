/**
 * @name Initialization Vector (IV) or nonces
 * @description Identifies potential sources for initialization vectors (IV) or nonce values
 *              utilized in block cipher operations within supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify block cipher modes and extract their initialization vector or nonce sources
from BlockMode blockCipherMode
select blockCipherMode.getIVorNonce().asExpr(), "Block mode IV/Nonce source"
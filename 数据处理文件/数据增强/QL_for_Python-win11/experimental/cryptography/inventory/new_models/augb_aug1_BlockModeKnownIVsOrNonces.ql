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

// Identify cryptographic block modes that provide initialization vectors or nonces
// These values are critical for secure cipher operations and quantum-resistant analysis
from BlockMode cipherMode
select cipherMode.getIVorNonce().asExpr(), "Block mode IV/Nonce source"
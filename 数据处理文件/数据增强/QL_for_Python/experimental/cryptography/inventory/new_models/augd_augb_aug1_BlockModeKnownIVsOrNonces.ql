/**
 * @name Initialization Vector (IV) or Nonce Sources
 * @description Identifies initialization vectors (IV) or nonce values used in 
 *              cryptographic block cipher operations. This detection supports 
 *              quantum readiness analysis by locating cryptographic components 
 *              potentially vulnerable to quantum computing attacks.
 * @kind problem
 * @id py/quantum-readiness/cbom/iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Locate cryptographic block modes that generate initialization vectors or nonces
// These values are essential for secure cipher operations and quantum resilience assessment
from BlockMode blockMode
select blockMode.getIVorNonce().asExpr(), "Block mode IV/Nonce source"
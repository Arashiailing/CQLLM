/**
 * @name Initialization Vector (IV) or Nonce Sources
 * @description Identifies potential origins of initialization vectors (IV) or nonce values
 *              utilized in block cipher operations across various cryptographic libraries.
 *              This analysis aids in pinpointing cryptographic elements susceptible to
 *              quantum computing threats by exposing the sources of these crucial values.
 * @kind problem
 * @id py/quantum-readiness/cbom/iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Locate cryptographic initialization vectors or nonces
// originating from block cipher operational modes
from BlockMode blockCipherMode
select blockCipherMode.getIVorNonce().asExpr(), "Block mode IV/Nonce source"
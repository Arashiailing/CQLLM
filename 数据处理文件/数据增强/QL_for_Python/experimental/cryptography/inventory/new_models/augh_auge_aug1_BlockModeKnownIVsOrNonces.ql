/**
 * @name Initialization Vector (IV) or Nonce Sources
 * @description Identifies potential initialization vectors (IV) or nonce values 
 *              utilized in block cipher operations across various cryptographic libraries.
 *              This detection helps pinpoint cryptographic components that may be
 *              susceptible to quantum computing attacks.
 * @kind problem
 * @id py/quantum-readiness/cbom/iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Extract block cipher mode instances from the codebase
// These instances are cryptographic operations that require IV or nonce values
from BlockMode blockCipherMode

// Retrieve the IV or nonce expression from each block cipher mode
// The asExpr() method converts the cryptographic value to its source code representation
select blockCipherMode.getIVorNonce().asExpr(), "Block mode IV/Nonce source"
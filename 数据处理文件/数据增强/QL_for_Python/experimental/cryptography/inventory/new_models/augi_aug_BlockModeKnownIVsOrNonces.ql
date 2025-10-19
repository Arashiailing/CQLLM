/**
 * @name Initialization Vector (IV) or Nonce Sources
 * @description Detects potential sources of initialization vectors (IV) or nonce values 
 *              employed in block cipher operations within supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python // Import Python language library for analyzing Python code
import experimental.cryptography.Concepts // Import experimental cryptographic concepts for handling encryption-related patterns

// Define a variable to represent block cipher modes
from BlockMode blockCipherMode

// Extract and select the IV or nonce source expressions from block cipher modes
select blockCipherMode.getIVorNonce().asExpr(), "Block mode IV/Nonce source"
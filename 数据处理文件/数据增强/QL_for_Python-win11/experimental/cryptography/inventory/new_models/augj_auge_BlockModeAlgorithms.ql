/**
 * @name Block cipher mode of operation
 * @description Identifies cryptographic operations utilizing block cipher modes from supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language analysis capabilities
import python

// Import experimental cryptographic concepts for mode detection
import experimental.cryptography.Concepts

// Define source for cryptographic block mode operations
from BlockMode cipherModeOperation

// Generate findings for each detected block cipher mode with algorithm identification
select cipherModeOperation, "Use of algorithm " + cipherModeOperation.getBlockModeName()
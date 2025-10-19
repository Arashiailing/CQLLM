/**
 * @name Block cipher mode of operation
 * @description Detects all uses of block cipher modes of operation from supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language support for code analysis
import python

// Import experimental cryptography concepts for cryptographic operation analysis
import experimental.cryptography.Concepts

// Identify block cipher mode instances from cryptographic libraries
from BlockMode blockCipherMode

// Report detected block cipher modes with operation details
select blockCipherMode, "Use of algorithm " + blockCipherMode.getBlockModeName()
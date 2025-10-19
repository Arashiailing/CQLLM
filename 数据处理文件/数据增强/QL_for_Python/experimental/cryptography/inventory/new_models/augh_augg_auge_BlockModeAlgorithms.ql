/**
 * @name Block cipher mode of operation
 * @description Detects all occurrences of block cipher modes in supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import necessary Python language support for code analysis
import python

// Import experimental cryptography concepts for analyzing cryptographic operations
import experimental.cryptography.Concepts

// Define the source of block cipher modes
from BlockMode cipherMode

// Report each detected block cipher mode with its algorithm name
select cipherMode, "Use of algorithm " + cipherMode.getBlockModeName()
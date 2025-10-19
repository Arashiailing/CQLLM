/**
 * @name Block cipher mode of operation detection
 * @description This query systematically identifies and reports all occurrences of block cipher 
 *              modes within Python codebases. It performs comprehensive analysis of cryptographic 
 *              operations across supported cryptographic libraries to detect implementation patterns.
 * @kind problem
 * @id py/quantum-readiness/cbom/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import necessary analysis frameworks for Python and cryptographic operations
import python
import experimental.cryptography.Concepts

// Main analysis: Identify all block cipher mode implementations in the codebase
from BlockMode detectedBlockCipherMode

// Generate results with detailed information about each detected mode
select detectedBlockCipherMode, 
       "Use of algorithm " + detectedBlockCipherMode.getBlockModeName()
/**
 * @name Detection of Block Cipher Modes
 * @description Discovers all occurrences of block cipher operational modes
 *              throughout supported cryptographic libraries within Python codebases
 * @kind problem
 * @id py/quantum-readiness/cbom/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import necessary modules for analysis
import python
import experimental.cryptography.Concepts

// Define the source of block cipher mode instances
from BlockMode blockCipherMode

// Project results with algorithm identification
select blockCipherMode, 
       "Algorithm in use: " + blockCipherMode.getBlockModeName()
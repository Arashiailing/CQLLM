/**
 * @name Block Cipher Mode Detection
 * @description Identifies occurrences of block cipher modes in Python codebases
 *              by scanning cryptographic operations across various supported libraries.
 *              This helps in understanding the cryptographic footprint of the codebase
 *              for quantum readiness assessment.
 * @kind problem
 * @id py/quantum-readiness/cbom/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import fundamental Python analysis capabilities
import python

// Import cryptographic concepts and operations analysis framework
import experimental.cryptography.Concepts

// Define source: All block cipher mode implementations in the codebase
from BlockMode detectedMode

// Generate output: Display detected modes with identification messages
select detectedMode, 
       "Identified block cipher mode: " + detectedMode.getBlockModeName()
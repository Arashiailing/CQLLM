/**
 * @name Block cipher mode detection
 * @description Identifies all instances of block cipher modes of operation 
 *              across supported cryptographic libraries in Python codebases.
 *              This analysis supports cryptographic inventory and assessment.
 * @kind problem
 * @id py/quantum-readiness/cbom/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python language support for code analysis
import python

// Import cryptographic concepts library for block cipher mode detection
import experimental.cryptography.Concepts

// Source of all block cipher mode instances in the codebase
from BlockMode cipherModeInstance

// Project results with algorithm identification for each detected mode
select cipherModeInstance, 
       "Algorithm in use: " + cipherModeInstance.getBlockModeName()
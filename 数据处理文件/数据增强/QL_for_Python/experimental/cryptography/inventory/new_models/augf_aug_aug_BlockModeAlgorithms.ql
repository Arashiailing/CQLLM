/**
 * @name Block cipher mode detection
 * @description Identifies all instances of block cipher modes of operation 
 *              across supported cryptographic libraries in Python codebases
 * @kind problem
 * @id py/quantum-readiness/cbom/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Core Python language support for code analysis
import python

// Cryptographic concepts library for operation detection
import experimental.cryptography.Concepts

// Source of block cipher mode instances
from BlockMode blockCipherMode

// Result projection with algorithm identification
select blockCipherMode, 
       "Algorithm in use: " + blockCipherMode.getBlockModeName()
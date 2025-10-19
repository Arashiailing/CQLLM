/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description Discovers and catalogs all cryptographic algorithm implementations throughout the codebase,
 *              utilizing supported cryptographic libraries for comprehensive detection.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import essential Python language analysis framework
import python

// Import specialized utilities for detecting cryptographic implementations
import experimental.cryptography.Concepts

// Source definition: Identify all cryptographic algorithm instances in the codebase
from CryptographicAlgorithm cipherImpl

// Result generation: Output each detected algorithm with its identifying name
select cipherImpl, 
       "Cryptographic algorithm implementation detected: " + cipherImpl.getName()
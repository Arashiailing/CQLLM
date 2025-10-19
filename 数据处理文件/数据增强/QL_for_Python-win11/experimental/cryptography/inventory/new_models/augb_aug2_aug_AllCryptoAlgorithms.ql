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

// Import core Python analysis capabilities
import python

// Import experimental cryptography detection utilities
import experimental.cryptography.Concepts

// Define the source for cryptographic algorithm detection
from CryptographicAlgorithm cryptoImpl

// Generate results with algorithm identification details
select cryptoImpl, 
       "Cryptographic algorithm implementation detected: " + cryptoImpl.getName()
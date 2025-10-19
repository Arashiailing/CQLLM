/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description Discovers and catalogs all cryptographic algorithm implementations throughout the codebase,
 *              utilizing supported cryptographic libraries for comprehensive detection and analysis.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import essential Python analysis capabilities for code examination
import python

// Import experimental cryptography detection framework for algorithm identification
import experimental.cryptography.Concepts

// Define the source of cryptographic algorithm implementations
from CryptographicAlgorithm cryptoAlgorithmInstance

// Generate detailed results with algorithm identification and classification
select cryptoAlgorithmInstance, 
       "Cryptographic algorithm implementation detected: " + cryptoAlgorithmInstance.getName()
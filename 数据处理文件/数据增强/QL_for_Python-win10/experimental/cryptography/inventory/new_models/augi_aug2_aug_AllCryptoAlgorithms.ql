/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description Discovers and catalogs every cryptographic algorithm implementation
 *              throughout the entire codebase by utilizing supported cryptographic
 *              libraries for comprehensive detection.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import essential Python code analysis capabilities
import python

// Import experimental framework for cryptography detection and analysis
import experimental.cryptography.Concepts

// Main query logic to identify cryptographic algorithm implementations
// The CryptographicAlgorithm class represents all detected implementations
// from supported cryptographic libraries in the codebase

// Define the source of cryptographic algorithms for analysis
from CryptographicAlgorithm cryptoAlgorithm

// Generate results with identification messages for each algorithm
// The message includes the algorithm name for easy reference
select cryptoAlgorithm, "Cryptographic algorithm implementation detected: " + cryptoAlgorithm.getName()
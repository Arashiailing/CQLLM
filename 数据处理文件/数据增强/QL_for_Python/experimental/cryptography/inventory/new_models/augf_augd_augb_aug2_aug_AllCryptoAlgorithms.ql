/**
 * @name Complete Cryptographic Implementation Detection
 * @description Discovers and documents all cryptographic algorithm implementations
 *              throughout the codebase by leveraging supported cryptographic libraries
 *              for comprehensive security analysis.
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

// Identify all cryptographic algorithm implementations in the codebase
from CryptographicAlgorithm cipherAlgorithm

// Report each detected cryptographic algorithm with its name
select cipherAlgorithm, 
       "Cryptographic algorithm" + " implementation detected: " + cipherAlgorithm.getName()
/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description Identifies and enumerates all cryptographic algorithm implementations across the codebase,
 *              leveraging supported cryptographic libraries for thorough detection and analysis.
 *              This query serves as a foundational component for Cryptographic Bill of Materials (CBOM) generation.
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
from CryptographicAlgorithm cryptoAlgoImpl

// Generate results with algorithm identification details
select cryptoAlgoImpl, 
       "Cryptographic algorithm implementation detected: " + cryptoAlgoImpl.getName()
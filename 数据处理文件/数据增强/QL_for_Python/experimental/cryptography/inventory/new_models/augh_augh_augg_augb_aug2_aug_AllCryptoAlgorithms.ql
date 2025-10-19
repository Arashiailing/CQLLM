/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description This query systematically identifies and catalogs all cryptographic algorithm implementations 
 *              throughout the codebase. It utilizes supported cryptographic libraries to ensure comprehensive 
 *              detection and analysis. The output serves as a critical foundation for generating a 
 *              Cryptographic Bill of Materials (CBOM), enabling organizations to assess their cryptographic 
 *              posture and quantum readiness.
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
from CryptographicAlgorithm cryptoAlgorithm

// Generate results with algorithm identification details
select cryptoAlgorithm, 
       "Detected cryptographic algorithm implementation: " + cryptoAlgorithm.getName()
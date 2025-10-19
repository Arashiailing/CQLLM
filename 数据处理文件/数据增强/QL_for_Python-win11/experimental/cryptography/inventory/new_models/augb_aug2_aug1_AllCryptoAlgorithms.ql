/**
 * @name All Cryptographic Algorithms
 * @description Identifies and reports all cryptographic algorithm implementations found in the codebase.
 *              This query scans through supported libraries to detect any usage of cryptographic algorithms,
 *              which is essential for generating a comprehensive Cryptographic Bill of Materials (CBOM).
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import required modules for Python analysis and cryptography detection
import python
import experimental.cryptography.Concepts

// Define the main query to identify all cryptographic algorithms
from CryptographicAlgorithm cryptoAlgorithm
// Format the alert message with the algorithm name
select cryptoAlgorithm, "Use of algorithm " + cryptoAlgorithm.getName()
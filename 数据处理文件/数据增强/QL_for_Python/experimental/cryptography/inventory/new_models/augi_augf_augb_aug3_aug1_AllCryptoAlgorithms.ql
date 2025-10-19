/**
 * @name Complete Cryptographic Algorithm Inventory
 * @description Comprehensive detection and cataloging of all cryptographic algorithm 
 *              implementations across supported cryptographic libraries. This query identifies
 *              and reports every cryptographic algorithm usage in the codebase, providing
 *              a complete inventory for cryptographic bill of materials (CBOM) generation
 *              and quantum readiness assessment.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core analysis modules required for cryptographic detection
import python
import experimental.cryptography.Concepts

// Define the main query logic to identify all cryptographic algorithm implementations
// This serves as the foundation for comprehensive cryptographic inventory
from CryptographicAlgorithm detectedCryptoAlgorithm

// Generate detailed alert messages for each detected cryptographic algorithm
// The output includes the algorithm implementation and a descriptive message
select detectedCryptoAlgorithm, 
       "Cryptographic algorithm detected: " + detectedCryptoAlgorithm.getName()
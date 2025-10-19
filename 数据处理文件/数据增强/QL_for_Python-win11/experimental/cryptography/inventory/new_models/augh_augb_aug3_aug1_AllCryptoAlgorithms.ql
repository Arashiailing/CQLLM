/**
 * @name Complete Cryptographic Algorithm Inventory
 * @description Comprehensive detection and cataloging of all cryptographic algorithm 
 *              implementations across supported cryptographic libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import essential modules for cryptographic analysis functionality
import python
import experimental.cryptography.Concepts

// Discover and catalog every cryptographic algorithm implementation 
// throughout the entire codebase for comprehensive inventory
from CryptographicAlgorithm detectedCryptoAlgorithm

// Produce detection notification containing detailed algorithm 
// identification information for reporting purposes
select detectedCryptoAlgorithm, 
       "Cryptographic algorithm detected: " + detectedCryptoAlgorithm.getName()
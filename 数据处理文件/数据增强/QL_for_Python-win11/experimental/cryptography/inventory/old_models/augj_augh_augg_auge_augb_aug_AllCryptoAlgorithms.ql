/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description Identifies all cryptographic algorithm implementations across supported libraries.
 *              This query detects both algorithm names and block modes used in cryptographic operations.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python and Semmle core libraries
import python
import semmle.python.Concepts

// Define the source of cryptographic operations and their algorithm identifiers
from Cryptography::CryptographicOperation cryptographicOperation, string algorithmIdentifier
where 
  // Retrieve either the algorithm name or block mode from the cryptographic operation
  exists(string algoName, string blockMode |
    algoName = cryptographicOperation.getAlgorithm().getName() and
    blockMode = cryptographicOperation.getBlockMode() and
    (algorithmIdentifier = algoName or algorithmIdentifier = blockMode)
  )
select cryptographicOperation, "Use of algorithm " + algorithmIdentifier
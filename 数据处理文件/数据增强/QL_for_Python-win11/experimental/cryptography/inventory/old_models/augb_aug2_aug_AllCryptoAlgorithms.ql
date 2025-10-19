/**
 * @name All Cryptographic Algorithms
 * @description Identifies all cryptographic algorithm implementations across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import necessary Python and Semmle core libraries for cryptographic analysis
import python
import semmle.python.Concepts

// Define the main query to detect cryptographic operations and extract algorithm information
from Cryptography::CryptographicOperation cryptoOperation, string algorithmIdentifier
where 
  // Primary case: Extract the algorithm name directly from the cryptographic operation
  algorithmIdentifier = cryptoOperation.getAlgorithm().getName()
  or
  // Secondary case: Extract the block mode information from the cryptographic operation
  algorithmIdentifier = cryptoOperation.getBlockMode()
select cryptoOperation, "Use of algorithm " + algorithmIdentifier
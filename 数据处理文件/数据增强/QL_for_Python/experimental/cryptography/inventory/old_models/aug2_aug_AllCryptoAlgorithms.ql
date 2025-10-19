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
from Cryptography::CryptographicOperation cryptographicOp, string algoIdentifier
where 
  // Case 1: Extract the algorithm name directly from the cryptographic operation
  algoIdentifier = cryptographicOp.getAlgorithm().getName()
  or
  // Case 2: Extract the block mode information from the cryptographic operation
  algoIdentifier = cryptographicOp.getBlockMode()
select cryptographicOp, "Use of algorithm " + algoIdentifier
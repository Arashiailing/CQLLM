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

// Identify cryptographic operations and extract algorithm identifiers
from Cryptography::CryptographicOperation cryptoOp, string algoId
where 
  // Extract algorithm name from cryptographic operation
  algoId = cryptoOp.getAlgorithm().getName()
  or
  // Extract block mode from cryptographic operation
  algoId = cryptoOp.getBlockMode()
select cryptoOp, "Use of algorithm " + algoId
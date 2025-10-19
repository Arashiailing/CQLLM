/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description Discovers and catalogs all cryptographic algorithm implementations across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis modules and Semmle cryptographic concepts
import python
import semmle.python.Concepts

// Define variables for cryptographic operations and algorithm identification
from Cryptography::CryptographicOperation cryptoOp, string algoName
where 
  // Primary extraction method: Direct algorithm name retrieval
  algoName = cryptoOp.getAlgorithm().getName()
  or
  // Secondary extraction method: Block mode information retrieval
  algoName = cryptoOp.getBlockMode()
select cryptoOp, "Use of algorithm " + algoName
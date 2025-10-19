/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description Discovers and catalogs all cryptographic algorithm implementations 
 *              across supported libraries in the codebase.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import required modules for Python code analysis and cryptographic concept detection
import python
import semmle.python.Concepts

// Main query to identify cryptographic operations and extract their algorithm details
from Cryptography::CryptographicOperation cryptoOp, string algoName
where 
  // First condition: Direct extraction of the algorithm name from the cryptographic operation
  algoName = cryptoOp.getAlgorithm().getName()
  or
  // Second condition: Extraction of block mode information when available
  algoName = cryptoOp.getBlockMode()
select cryptoOp, "Use of algorithm " + algoName
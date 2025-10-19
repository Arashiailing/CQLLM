/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description Identifies all cryptographic algorithm implementations across supported libraries,
 *              including both core algorithms and block cipher modes.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Core imports: Python language support and cryptographic security concepts
import python
import semmle.python.Concepts

// Identify cryptographic operations and extract algorithm identifiers
from Cryptography::CryptographicOperation cryptographicOperation, string algorithmIdentifier
where 
  // Capture either the primary algorithm name or block cipher mode
  algorithmIdentifier = cryptographicOperation.getAlgorithm().getName()
  or
  algorithmIdentifier = cryptographicOperation.getBlockMode()
select cryptographicOperation, "Detected cryptographic algorithm: " + algorithmIdentifier
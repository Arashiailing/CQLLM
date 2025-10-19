/**
 * @name Elliptic Curve Cryptography Implementation Detection
 * @description Identifies elliptic curve cryptographic algorithm implementations across multiple cryptographic libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python language support modules
import python

// Import experimental cryptographic concepts and definitions
import experimental.cryptography.Concepts

// Identify all elliptic curve cryptographic algorithm implementations
from EllipticCurveAlgorithm ecAlgorithmImpl

// Format and output detailed information for each identified implementation
select ecAlgorithmImpl,
  "Algorithm: " + ecAlgorithmImpl.getCurveName() + 
  " | Key Size (bits): " + ecAlgorithmImpl.getCurveBitSize().toString()
/**
 * @name Elliptic Curve Algorithms
 * @description Detects elliptic curve algorithm implementations across cryptographic libraries.
 *              Reports algorithm names and corresponding key sizes for quantum readiness assessment.
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python language support
import python
// Import cryptographic concepts library for algorithm definitions
import experimental.cryptography.Concepts

// Identify elliptic curve algorithm instances
from EllipticCurveAlgorithm ecAlgorithm
// Generate detailed algorithm description
select ecAlgorithm,
  "Algorithm: " + ecAlgorithm.getCurveName() + 
  " | Key Size (bits): " + ecAlgorithm.getCurveBitSize().toString()
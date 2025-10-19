/**
 * @name Elliptic Curve Algorithms
 * @description Identifies potential usage of elliptic curve algorithms across supported cryptographic libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python language support
import python
// Import experimental cryptographic concepts library
import experimental.cryptography.Concepts

// Identify elliptic curve algorithm instances
from EllipticCurveAlgorithm ellipticCurveAlgorithm
// Construct detailed algorithm description
select ellipticCurveAlgorithm,
  "Algorithm: " + ellipticCurveAlgorithm.getCurveName() + 
  " | Key Size (bits): " + ellipticCurveAlgorithm.getCurveBitSize().toString()
/**
 * @name Elliptic Curve Cryptography Detection
 * @description Detects implementations of elliptic curve cryptographic algorithms in various cryptographic libraries
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

// Find all elliptic curve cryptographic algorithm implementations
from EllipticCurveAlgorithm curveAlgorithm
// Generate detailed information about each detected elliptic curve algorithm
select curveAlgorithm,
  "Algorithm: " + curveAlgorithm.getCurveName() + 
  " | Key Size (bits): " + curveAlgorithm.getCurveBitSize().toString()
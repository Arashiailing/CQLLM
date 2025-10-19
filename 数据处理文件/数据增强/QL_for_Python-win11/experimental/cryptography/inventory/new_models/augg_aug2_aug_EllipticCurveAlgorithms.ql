/**
 * @name Elliptic Curve Cryptography Detection
 * @description Identifies implementations of elliptic curve cryptographic algorithms across various cryptographic libraries
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

// Identify all elliptic curve cryptographic algorithm implementations
from EllipticCurveAlgorithm ellipticCurveImpl
// Generate comprehensive details for each detected elliptic curve algorithm
select ellipticCurveImpl,
  "Algorithm: " + ellipticCurveImpl.getCurveName() + 
  " | Key Size (bits): " + ellipticCurveImpl.getCurveBitSize().toString()
/**
 * @name Elliptic Curve Cryptography Detection
 * @description Identifies implementations of elliptic curve cryptographic algorithms across cryptographic libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python language support
import python
// Import experimental cryptographic concept definitions
import experimental.cryptography.Concepts

// Identify elliptic curve cryptographic implementations
from EllipticCurveAlgorithm ellipticCurveImpl
select ellipticCurveImpl,
  ("Algorithm: " + ellipticCurveImpl.getCurveName()) + 
  (" | Key Size (bits): " + ellipticCurveImpl.getCurveBitSize().toString())
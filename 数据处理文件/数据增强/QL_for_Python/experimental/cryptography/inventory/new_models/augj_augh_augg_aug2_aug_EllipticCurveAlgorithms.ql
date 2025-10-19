/**
 * @name Elliptic Curve Cryptography Detection
 * @description Identifies implementations of elliptic curve cryptographic algorithms across various cryptographic libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python language analysis capabilities
import python
// Import experimental cryptographic concepts for elliptic curve identification
import experimental.cryptography.Concepts

// Define the main query to detect elliptic curve cryptographic implementations
from EllipticCurveAlgorithm ellipticCurveImpl
// Construct detailed output message containing algorithm specifications
select ellipticCurveImpl,
  "Algorithm: " + ellipticCurveImpl.getCurveName() + 
  " | Key Size (bits): " + ellipticCurveImpl.getCurveBitSize().toString()
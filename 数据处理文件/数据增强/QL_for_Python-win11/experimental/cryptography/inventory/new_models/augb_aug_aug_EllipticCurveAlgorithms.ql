/**
 * @name Elliptic Curve Algorithms Detection
 * @description Identifies elliptic curve cryptographic algorithm implementations 
 *              across supported Python cryptographic libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Core Python language analysis support
import python
// Cryptographic concepts and definitions library
import experimental.cryptography.Concepts

// Query to detect elliptic curve algorithm implementations
from EllipticCurveAlgorithm ellipticCurveInstance
// Construct detailed algorithm information message
select ellipticCurveInstance,
  // Algorithm identification section
  "Algorithm: " + ellipticCurveInstance.getCurveName() + 
  // Key size specification section
  " | Key Size (bits): " + ellipticCurveInstance.getCurveBitSize().toString()
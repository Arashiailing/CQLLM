/**
 * @name Elliptic Curve Cryptography Detection
 * @description Discovers implementations of elliptic curve cryptographic algorithms 
 *              within various Python cryptographic libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Fundamental Python language analysis capabilities
import python
// Cryptographic primitives and concepts definitions
import experimental.cryptography.Concepts

// Main detection query for elliptic curve cryptographic algorithms
from EllipticCurveAlgorithm ellipticCurveCrypto
// Construct detailed algorithm information message
select ellipticCurveCrypto,
  // Algorithm identification
  "Algorithm: " + ellipticCurveCrypto.getCurveName() + 
  // Key size specification
  " | Key Size (bits): " + ellipticCurveCrypto.getCurveBitSize().toString()
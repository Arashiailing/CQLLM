/**
 * @name Elliptic Curve Cryptography Algorithm Detection
 * @description Identifies and reports elliptic curve cryptographic algorithm implementations
 *              across supported Python cryptographic libraries in codebases
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python language support for analysis
import python
// Import experimental cryptographic concepts and definitions
import experimental.cryptography.Concepts

// Identify elliptic curve algorithm implementations
from EllipticCurveAlgorithm ellipticCurveAlgo
// Generate detailed algorithm information report
select ellipticCurveAlgo,
  // Construct algorithm identification string
  "Algorithm: " + ellipticCurveAlgo.getCurveName() + 
  // Append cryptographic key size details
  " | Key Size (bits): " + ellipticCurveAlgo.getCurveBitSize().toString()
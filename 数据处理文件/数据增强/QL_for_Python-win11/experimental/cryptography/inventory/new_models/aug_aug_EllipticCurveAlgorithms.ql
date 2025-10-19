/**
 * @name Elliptic Curve Algorithms Detection
 * @description Detects and reports the usage of elliptic curve cryptographic algorithms 
 *              within various supported cryptographic libraries in Python codebases
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

// Main query to identify elliptic curve algorithm implementations
from EllipticCurveAlgorithm ecAlgorithm
// Format the output message with algorithm details
select ecAlgorithm,
  // Construct detailed algorithm information string
  "Algorithm: " + ecAlgorithm.getCurveName() + 
  // Append key size information to the output
  " | Key Size (bits): " + ecAlgorithm.getCurveBitSize().toString()
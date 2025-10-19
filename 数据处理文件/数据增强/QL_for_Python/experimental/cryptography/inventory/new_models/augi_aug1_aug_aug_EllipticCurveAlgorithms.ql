/**
 * @name Elliptic Curve Cryptography Implementation Detection
 * @description Detects and catalogs elliptic curve cryptographic algorithm implementations 
 *              within various cryptographic libraries used in Python codebases
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import necessary Python language analysis components
import python
// Import experimental cryptographic framework with elliptic curve algorithm definitions
import experimental.cryptography.Concepts

// Main query clause to identify elliptic curve cryptographic implementations
from EllipticCurveAlgorithm ecAlgorithm
// Construct detailed output with algorithm information
select ecAlgorithm,
  // Format algorithm name and key size into a descriptive string
  "Algorithm: " + ecAlgorithm.getCurveName() + 
  " | Key Size (bits): " + ecAlgorithm.getCurveBitSize().toString()
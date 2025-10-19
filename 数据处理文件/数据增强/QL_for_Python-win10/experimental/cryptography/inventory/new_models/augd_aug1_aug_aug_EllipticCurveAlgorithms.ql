/**
 * @name Elliptic Curve Cryptography Implementation Detection
 * @description Discovers and catalogs elliptic curve cryptographic algorithm implementations
 *              within various Python cryptographic libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import necessary Python language modules for code analysis
import python
// Import experimental cryptographic framework with algorithm definitions
import experimental.cryptography.Concepts

// Main query logic to identify elliptic curve cryptographic implementations
from EllipticCurveAlgorithm ellipticCurveImpl
// Generate formatted output with algorithm details
select ellipticCurveImpl,
  // Construct detailed algorithm information string
  "Algorithm: " + ellipticCurveImpl.getCurveName() + 
  // Append key size information to the result
  " | Key Size (bits): " + ellipticCurveImpl.getCurveBitSize().toString()
/**
 * @name Elliptic Curve Algorithm Usage
 * @description Detects elliptic curve algorithm implementations in cryptographic libraries that may be vulnerable to quantum attacks
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

// Identify elliptic curve algorithm implementations
from EllipticCurveAlgorithm curveAlgo
// Generate detailed algorithm information
select curveAlgo,
  "Algorithm: " + curveAlgo.getCurveName() + 
  " | Key Size (bits): " + curveAlgo.getCurveBitSize().toString()
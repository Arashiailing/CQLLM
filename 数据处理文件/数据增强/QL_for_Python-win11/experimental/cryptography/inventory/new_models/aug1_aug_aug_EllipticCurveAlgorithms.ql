/**
 * @name Elliptic Curve Algorithms Detection
 * @description Identifies and documents the implementation of elliptic curve cryptography 
 *              algorithms across multiple cryptographic libraries in Python projects
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import essential Python language modules for code analysis
import python
// Import experimental cryptographic framework containing algorithm definitions
import experimental.cryptography.Concepts

// Primary query logic for locating elliptic curve cryptographic algorithms
from EllipticCurveAlgorithm curveCrypto
// Generate formatted output containing algorithm specifics
select curveCrypto,
  // Build comprehensive algorithm description string
  "Algorithm: " + curveCrypto.getCurveName() + 
  // Include key size details in the result
  " | Key Size (bits): " + curveCrypto.getCurveBitSize().toString()
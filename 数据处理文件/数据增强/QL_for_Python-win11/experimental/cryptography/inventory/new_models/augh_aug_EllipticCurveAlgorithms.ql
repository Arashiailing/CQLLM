/**
 * @name Elliptic Curve Cryptography Detection
 * @description Detects the implementation of elliptic curve cryptographic algorithms in various cryptographic libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import fundamental Python language support
import python
// Import experimental cryptographic functionality definitions
import experimental.cryptography.Concepts

// Find and format information about elliptic curve cryptographic algorithms
from EllipticCurveAlgorithm ecAlgorithm
select ecAlgorithm,
  "Algorithm: " + ecAlgorithm.getCurveName() + 
  " | Key Size (bits): " + ecAlgorithm.getCurveBitSize().toString()
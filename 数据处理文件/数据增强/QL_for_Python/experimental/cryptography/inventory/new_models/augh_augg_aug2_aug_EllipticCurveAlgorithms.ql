/**
 * @name Elliptic Curve Cryptography Detection
 * @description Identifies implementations of elliptic curve cryptographic algorithms across various cryptographic libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Core Python language support for code analysis
import python
// Experimental cryptographic concepts for elliptic curve detection
import experimental.cryptography.Concepts

// Main detection logic for elliptic curve cryptographic implementations
from EllipticCurveAlgorithm ecAlgorithm
// Format output results with algorithm details and key specifications
select ecAlgorithm,
  "Algorithm: " + ecAlgorithm.getCurveName() + 
  " | Key Size (bits): " + ecAlgorithm.getCurveBitSize().toString()
/**
 * @name Elliptic Curve Cryptography Analysis
 * @description Identifies and reports elliptic curve cryptographic implementations 
 *              across various Python libraries. This analysis provides critical 
 *              information for quantum readiness assessment by detailing algorithm 
 *              names and their corresponding key sizes.
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python language support for code analysis
import python
// Import cryptographic concepts library containing algorithm definitions and classifications
import experimental.cryptography.Concepts

// Identify elliptic curve cryptographic implementations in the codebase
from EllipticCurveAlgorithm curveCrypto
// Format and report algorithm details including curve name and key size
select curveCrypto,
  "Algorithm: " + curveCrypto.getCurveName() + 
  " | Key Size (bits): " + curveCrypto.getCurveBitSize().toString()
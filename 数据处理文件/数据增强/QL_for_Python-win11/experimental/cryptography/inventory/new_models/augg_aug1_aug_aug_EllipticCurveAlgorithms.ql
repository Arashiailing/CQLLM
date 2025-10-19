/**
 * @name Elliptic Curve Cryptography Implementation Detection
 * @description Detects and catalogs elliptic curve cryptography implementations
 *              within Python cryptographic libraries for CBOM analysis
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import necessary Python language analysis modules
import python

// Import experimental cryptographic framework with elliptic curve definitions
import experimental.cryptography.Concepts

// Main query logic to identify elliptic curve cryptographic algorithm implementations
from EllipticCurveAlgorithm ecAlgorithm

// Generate formatted output containing algorithm name and key size details
select ecAlgorithm,
  "Algorithm: " + ecAlgorithm.getCurveName() + 
  " | Key Size (bits): " + ecAlgorithm.getCurveBitSize().toString()
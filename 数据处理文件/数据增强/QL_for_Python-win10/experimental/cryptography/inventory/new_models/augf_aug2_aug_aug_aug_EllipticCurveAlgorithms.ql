/**
 * @name Elliptic Curve Algorithms Detection
 * @description Identifies elliptic curve cryptographic algorithm usage across the codebase.
 *              Extracts curve name and key size data for quantum readiness assessment.
 *              Critical for cryptographic inventory due to quantum vulnerability of ECC.
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis module
import python

// Import experimental cryptography analysis module
import experimental.cryptography.Concepts

// Define elliptic curve algorithm instances for analysis
from EllipticCurveAlgorithm eccAlgorithm

// Generate formatted report for each detected instance
select eccAlgorithm,
  "Algorithm: " + eccAlgorithm.getCurveName() + 
  " | Key Size (bits): " + eccAlgorithm.getCurveBitSize().toString()
/**
 * @name Elliptic Curve Cryptography Detection
 * @description Identifies elliptic curve cryptographic implementations across codebases.
 *              Extracts curve names and key sizes for quantum vulnerability assessment.
 *              Critical for cryptographic inventory due to ECC's susceptibility to quantum attacks.
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

// Identify elliptic curve algorithm instances for analysis
from EllipticCurveAlgorithm eccInstance

// Extract curve properties and format output
select eccInstance,
  "Algorithm: " + eccInstance.getCurveName() + 
  " | Key Size (bits): " + eccInstance.getCurveBitSize().toString()
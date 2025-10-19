/**
 * @name Elliptic Curve Cryptography Detection
 * @description Identifies and catalogs elliptic curve cryptographic implementations across codebases.
 *              This query extracts critical information including curve names and key sizes
 *              to facilitate quantum vulnerability assessment. The detection of ECC algorithms
 *              is essential for cryptographic inventory management due to their susceptibility
 *              to quantum computing attacks.
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import fundamental Python analysis capabilities
import python

// Import specialized cryptography analysis components
import experimental.cryptography.Concepts

// Define the source of elliptic curve cryptographic implementations
from EllipticCurveAlgorithm ellipticCurveImpl

// Format and present elliptic curve details for analysis
select ellipticCurveImpl,
  "Algorithm: " + ellipticCurveImpl.getCurveName() + 
  " | Key Size (bits): " + ellipticCurveImpl.getCurveBitSize().toString()
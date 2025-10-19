/**
 * @name Elliptic Curve Algorithms Detection
 * @description Detects all elliptic curve cryptographic algorithm implementations in the codebase.
 *              Extracts curve name and key size (bits) to assess quantum vulnerability.
 *              Elliptic curve cryptography is vulnerable to quantum attacks via Shor's algorithm,
 *              making this detection critical for cryptographic inventory and migration planning
 *              to post-quantum cryptographic standards.
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis capabilities
import python

// Import cryptographic concept definitions
import experimental.cryptography.Concepts

// Identify all elliptic curve cryptographic implementations
from EllipticCurveAlgorithm ellipticCurveInstance

// Format output with algorithm details and security metrics
select ellipticCurveInstance,
  "Algorithm: " + ellipticCurveInstance.getCurveName() + 
  " | Key Size (bits): " + ellipticCurveInstance.getCurveBitSize().toString()
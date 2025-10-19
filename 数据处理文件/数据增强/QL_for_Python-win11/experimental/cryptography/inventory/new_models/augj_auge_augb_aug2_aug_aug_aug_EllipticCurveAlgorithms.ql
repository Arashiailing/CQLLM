/**
 * @name Elliptic Curve Cryptography Detection
 * @description Identifies elliptic curve cryptographic implementations across codebases,
 *              extracting curve names and key sizes for quantum vulnerability assessment.
 *              Essential for cryptographic inventory management due to ECC's susceptibility
 *              to quantum computing attacks.
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis capabilities
import python

// Import specialized cryptography analysis modules
import experimental.cryptography.Concepts

// Define elliptic curve cryptographic algorithm source
from EllipticCurveAlgorithm eccAlgorithm

// Format and present elliptic curve cryptographic details
select eccAlgorithm,
  "Algorithm: " + eccAlgorithm.getCurveName() + 
  " | Key Size (bits): " + eccAlgorithm.getCurveBitSize().toString()
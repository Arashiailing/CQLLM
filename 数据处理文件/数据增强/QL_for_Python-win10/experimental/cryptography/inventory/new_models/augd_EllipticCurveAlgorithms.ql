/**
 * @name Elliptic Curve Algorithms
 * @description Identifies all potential usages of elliptic curve algorithms across supported cryptographic libraries.
 *              This query helps in assessing the quantum readiness of cryptographic implementations by detecting
 *              elliptic curve cryptography which may be vulnerable to quantum attacks.
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python language support
import python
// Import experimental cryptography concepts for analyzing cryptographic algorithms
import experimental.cryptography.Concepts

// Query to find all instances of elliptic curve algorithms
from EllipticCurveAlgorithm curveAlgorithm
// Construct a descriptive message for each identified algorithm
select curveAlgorithm,
  "Elliptic curve algorithm detected: " + curveAlgorithm.getCurveName() + 
  " with key strength of " + curveAlgorithm.getCurveBitSize().toString() + " bits"
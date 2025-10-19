/**
 * @name Detection of Elliptic Curve Algorithms
 * @description Identifies all occurrences of elliptic curve cryptographic algorithms in the codebase.
 *              This query extracts the curve name and key size details to assist in evaluating quantum readiness.
 *              Due to the vulnerability of elliptic curve cryptography to quantum attacks, this detection
 *              is essential for cryptographic inventory and migration planning.
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import the Python language analysis module
import python

// Import the experimental cryptography concepts module
import experimental.cryptography.Concepts

// Identify all elliptic curve algorithm instances in the codebase
from EllipticCurveAlgorithm curveAlgo

// Generate a report for each instance including curve name and key size
select curveAlgo,
  "Algorithm: " + curveAlgo.getCurveName() + 
  " | Key Size (bits): " + curveAlgo.getCurveBitSize().toString()
/**
 * @name Elliptic Curve Algorithms Detection
 * @description This query identifies all instances of elliptic curve cryptographic algorithms
 *              being used throughout the codebase. It extracts the curve name and key size
 *              information to help assess quantum readiness. Elliptic curve cryptography
 *              is vulnerable to quantum attacks, making this detection critical for
 *              cryptographic inventory and migration planning.
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
from EllipticCurveAlgorithm ecInstance

// Generate a report for each instance including curve name and key size
select ecInstance,
  "Algorithm: " + ecInstance.getCurveName() + 
  " | Key Size (bits): " + ecInstance.getCurveBitSize().toString()
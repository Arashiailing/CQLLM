/**
 * @name Elliptic Curve Cryptography Detection
 * @description Identifies all implementations of elliptic curve cryptographic algorithms within the codebase.
 *              This query extracts curve name and key size details to facilitate quantum vulnerability assessment.
 *              Since elliptic curve cryptography faces significant risks from quantum computing advances,
 *              this detection enables proper cryptographic inventory management and migration planning.
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import required modules for Python code analysis
import python

// Import experimental cryptography analysis framework
import experimental.cryptography.Concepts

// Find all elliptic curve cryptographic algorithm instances
from EllipticCurveAlgorithm eccInstance

// Prepare detailed information about each discovered elliptic curve implementation
select eccInstance,
  // Format the output to include both algorithm type and security parameters
  "Algorithm: " + eccInstance.getCurveName() + 
  " | Key Size (bits): " + eccInstance.getCurveBitSize().toString()
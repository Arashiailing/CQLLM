/**
 * @name Elliptic Curve Cryptography Detection
 * @description Discovers all elliptic curve cryptographic algorithm implementations throughout the codebase.
 *              This query captures curve name and key size information to help assess quantum vulnerability.
 *              Given that elliptic curve cryptography is susceptible to quantum computing threats,
 *              this identification is crucial for cryptographic asset management and transition strategies.
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import necessary modules for Python language analysis
import python

// Import experimental cryptography framework components
import experimental.cryptography.Concepts

// Locate all elliptic curve cryptographic implementations
from EllipticCurveAlgorithm ellipticCurveInstance

// Extract curve details for each identified instance
select ellipticCurveInstance,
  // Combine algorithm name and key size into a single report string
  "Algorithm: " + ellipticCurveInstance.getCurveName() + 
  " | Key Size (bits): " + ellipticCurveInstance.getCurveBitSize().toString()
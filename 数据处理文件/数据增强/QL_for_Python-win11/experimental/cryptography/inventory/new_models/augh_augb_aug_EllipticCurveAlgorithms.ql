/**
 * @name Elliptic Curve Cryptography Detection
 * @description Identifies implementations of elliptic curve cryptographic algorithms in various libraries.
 *              Provides curve names and key sizes for evaluating quantum computing resistance.
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import fundamental Python language analysis capabilities
import python
// Import cryptographic definitions and concepts for algorithm detection
import experimental.cryptography.Concepts

// Define source of elliptic curve cryptographic implementations
from EllipticCurveAlgorithm curveCryptoImpl

// Extract curve name and bit size for each implementation
select curveCryptoImpl,
  "Algorithm: " + curveCryptoImpl.getCurveName() + 
  " | Key Size (bits): " + curveCryptoImpl.getCurveBitSize().toString()
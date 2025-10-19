/**
 * @name Elliptic Curve Cryptography Detection
 * @description This query systematically identifies all elliptic curve cryptographic 
 *              algorithm implementations throughout the codebase. It extracts critical
 *              information including curve names and key sizes to assess quantum 
 *              vulnerability. Given that ECC algorithms are vulnerable to quantum 
 *              computing attacks, this detection is crucial for cryptographic asset 
 *              inventory management and quantum transition strategy development.
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveInstance
select ellipticCurveInstance,
  "Algorithm: " + ellipticCurveInstance.getCurveName() + 
  " | Key Size (bits): " + ellipticCurveInstance.getCurveBitSize().toString()
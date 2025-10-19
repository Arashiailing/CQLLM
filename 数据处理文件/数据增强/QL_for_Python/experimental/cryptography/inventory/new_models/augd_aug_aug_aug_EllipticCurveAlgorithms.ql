/**
 * @name Elliptic Curve Cryptography Detection
 * @description Identifies all elliptic curve cryptographic algorithm implementations
 *              in the codebase. Extracts curve name and key size details to evaluate
 *              quantum vulnerability. ECC is susceptible to quantum attacks, making
 *              this detection essential for cryptographic asset management and
 *              quantum transition planning.
 * @kind problem
 * @id py/quantum-readiness/cbom/elliptic-curve-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ecAlgorithm
select ecAlgorithm,
  "Algorithm: " + ecAlgorithm.getCurveName() + 
  " | Key Size (bits): " + ecAlgorithm.getCurveBitSize().toString()
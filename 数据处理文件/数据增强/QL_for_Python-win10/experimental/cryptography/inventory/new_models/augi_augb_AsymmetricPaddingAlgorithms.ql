/**
 * @name Asymmetric Padding Schemes Detection
 * @description Identifies all cryptographic algorithms utilizing asymmetric padding schemes.
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from AsymmetricPadding asymmetricPadding

select asymmetricPadding, 
  "Algorithm uses padding scheme: " + asymmetricPadding.getPaddingName()
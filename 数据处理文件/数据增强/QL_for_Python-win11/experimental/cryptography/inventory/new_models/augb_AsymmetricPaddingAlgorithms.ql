/**
 * @name Asymmetric Padding Schemes
 * @description Identifies all potential uses of padding schemes with asymmetric cryptographic algorithms.
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from AsymmetricPadding paddingScheme

select paddingScheme, 
  "Algorithm uses padding scheme: " + paddingScheme.getPaddingName()
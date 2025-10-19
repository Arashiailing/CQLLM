/**
 * @name Asymmetric Padding Schemes
 * @description Identifies all potential uses of padding schemes in asymmetric cryptographic algorithms.
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Query all asymmetric padding scheme instances
from AsymmetricPadding paddingScheme
select paddingScheme, "Use of algorithm " + paddingScheme.getPaddingName()
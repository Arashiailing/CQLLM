/**
 * @name Asymmetric Padding Schemes
 * @description Identifies all implementations of asymmetric cryptographic padding schemes
 *              that may require quantum-resistant alternatives.
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding scheme implementations
from AsymmetricPadding paddingScheme

// Generate alert with algorithm name and contextual description
select paddingScheme, "Detected asymmetric padding scheme: " + paddingScheme.getPaddingName()
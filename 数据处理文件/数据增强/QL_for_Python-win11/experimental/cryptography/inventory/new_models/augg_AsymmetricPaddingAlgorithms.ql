/**
 * @name Asymmetric Padding Schemes
 * @description Identifies all potential implementations of asymmetric cryptographic padding schemes.
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Query for asymmetric padding scheme implementations
from AsymmetricPadding asymmetricPaddingScheme
select asymmetricPaddingScheme, 
       "Detected asymmetric padding scheme: " + asymmetricPaddingScheme.getPaddingName()
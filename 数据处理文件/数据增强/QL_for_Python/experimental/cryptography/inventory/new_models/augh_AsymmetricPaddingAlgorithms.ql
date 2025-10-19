/**
 * @name Asymmetric Padding Schemes
 * @description Identifies all instances of asymmetric cryptographic padding schemes
 *              that may pose security risks in quantum computing environments.
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
       "Detected asymmetric padding scheme: " + asymmetricPadding.getPaddingName() + 
       " - Consider quantum-resistant alternatives"
/**
 * @name Asymmetric Padding Schemes
 * @description Detects implementations of asymmetric cryptographic padding schemes that may introduce quantum vulnerabilities.
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify all asymmetric padding scheme implementations
from AsymmetricPadding paddingImpl
select paddingImpl, 
       "Detected asymmetric padding scheme: " + paddingImpl.getPaddingName()
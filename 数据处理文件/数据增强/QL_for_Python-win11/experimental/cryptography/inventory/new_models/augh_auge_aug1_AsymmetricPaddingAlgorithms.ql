/**
 * @name Asymmetric Cryptographic Padding Detection
 * @description Identifies all asymmetric encryption padding techniques in codebase
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric encryption padding implementations
from AsymmetricPadding asymmetricPadding

// Report padding method with contextual description
select asymmetricPadding, "Detected asymmetric padding scheme: " + asymmetricPadding.getPaddingName()
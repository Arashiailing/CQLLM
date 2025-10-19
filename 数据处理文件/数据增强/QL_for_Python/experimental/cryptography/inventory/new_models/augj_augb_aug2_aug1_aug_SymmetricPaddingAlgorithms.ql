/**
 * @name Quantum Vulnerability: Symmetric Encryption Using Padding
 * @description Identifies symmetric encryption algorithms that utilize padding schemes, which can be
 *              vulnerable in quantum computing environments. Padding mechanisms in traditional symmetric
 *              encryption may introduce weaknesses that quantum computers could exploit. This detection
 *              helps identify cryptographic implementations that should be replaced with quantum-resistant
 *              alternatives to ensure long-term security.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding symmetricCipherWithPadding
select symmetricCipherWithPadding, 
       "Identified symmetric encryption with padding: " + symmetricCipherWithPadding.getPaddingName()
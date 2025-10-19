/**
 * @name Quantum-Vulnerable Symmetric Encryption with Padding
 * @description Identifies symmetric encryption algorithms that employ padding techniques.
 *              The use of padding in symmetric encryption can create security weaknesses
 *              that are especially susceptible to exploitation in quantum computing contexts.
 *              Conventional symmetric ciphers with padding may not provide adequate protection
 *              against quantum-based attacks, necessitating their detection and replacement
 *              with quantum-resistant cryptographic solutions.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding vulnerableCipherWithPadding
select vulnerableCipherWithPadding, 
       "Detected symmetric encryption using padding: " + vulnerableCipherWithPadding.getPaddingName()
/**
 * @name Symmetric Encryption with Padding Vulnerable to Quantum Attacks
 * @description Detects symmetric encryption algorithms that utilize padding techniques.
 *              Padding mechanisms in symmetric encryption can introduce security weaknesses
 *              that become particularly exploitable in quantum computing environments.
 *              Traditional symmetric ciphers with padding may not withstand quantum-based attacks,
 *              requiring identification and replacement with quantum-resistant alternatives.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding vulnerableSymmetricCipher
select vulnerableSymmetricCipher, 
       "Detected symmetric encryption using padding: " + vulnerableSymmetricCipher.getPaddingName()
/**
 * @name Quantum-Vulnerable Symmetric Encryption with Padding
 * @description Detects symmetric encryption implementations utilizing padding mechanisms.
 *              Padding schemes in symmetric encryption can introduce security vulnerabilities
 *              that are particularly exploitable in quantum computing environments. Traditional
 *              symmetric ciphers with padding may become insufficient against quantum attacks,
 *              requiring identification and replacement with quantum-resistant alternatives.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding paddedSymmetricCipher
select paddedSymmetricCipher, 
       "Detected symmetric encryption using padding: " + paddedSymmetricCipher.getPaddingName()
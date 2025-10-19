/**
 * @name Quantum-Vulnerable Symmetric Encryption with Padding
 * @description Identifies symmetric encryption implementations employing padding mechanisms.
 *              Padding schemes in symmetric encryption can introduce security weaknesses
 *              that are particularly susceptible to exploitation in quantum computing environments. 
 *              Conventional symmetric ciphers with padding may become inadequate against quantum attacks,
 *              requiring detection and replacement with quantum-resistant alternatives.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding vulnerableCipher
select vulnerableCipher, 
       "Identified symmetric encryption with padding: " + vulnerableCipher.getPaddingName()
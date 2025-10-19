/**
 * @name Quantum Vulnerability: Symmetric Encryption with Padding
 * @description Detects symmetric encryption implementations that employ padding mechanisms.
 *              In quantum computing contexts, traditional symmetric encryption with padding
 *              may be susceptible to enhanced attacks. Quantum algorithms could potentially
 *              exploit padding oracle vulnerabilities or reduce the effective security strength
 *              of padded symmetric ciphers. This query identifies such implementations to
 *              facilitate migration towards quantum-resistant cryptographic solutions.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding encryptionWithPadding
select encryptionWithPadding, 
       "Identified symmetric encryption with padding: " + encryptionWithPadding.getPaddingName()
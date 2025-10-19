/**
 * @name Symmetric Encryption Padding Detection
 * @description Identifies cryptographic padding schemes applied with symmetric encryption algorithms.
 *              This query flags padding mechanisms used in symmetric ciphers that may introduce
 *              security vulnerabilities or compliance issues.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 *       quantum-readiness
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding symmetricPadding
select symmetricPadding,
       "Detected symmetric encryption using padding scheme: " + symmetricPadding.getPaddingName()
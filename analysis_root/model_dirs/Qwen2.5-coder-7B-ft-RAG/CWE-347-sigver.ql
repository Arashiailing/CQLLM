/**
 * @name CWE-347: Improper Verification of Cryptographic Signature
 * @description The product does not verify, or incorrectly verifies, the cryptographic signature for data.
 * @kind problem
 * @problem.severity warning
 * @id py/sigver
 */

import python
import experimental.sigver.CryptoSignaturesVerification
import CryptoSignaturesVerification::VerifiedSignature sigverify
/**
 * @name CWE-347: Improper Verification of Cryptographic Signature
 * @description The product does not verify, or incorrectly verifies, the cryptographic signature for data.
 * @id py/sigver
 */
import python
import experimental.semmle.python.security.SignatureVerification

predicate isImproperlyVerifiedSignature(AstNode sigVerif) {
  sigVerif instanceof SignatureVerification::Verify && not sigVerif.isCorrectlyVerified()
}

from SignatureVerification::Verify sigVerif
where isImproperlyVerifiedSignature(sigVerif)
select sigVerif, "This code improperly verifies or does not verify the cryptographic signature."
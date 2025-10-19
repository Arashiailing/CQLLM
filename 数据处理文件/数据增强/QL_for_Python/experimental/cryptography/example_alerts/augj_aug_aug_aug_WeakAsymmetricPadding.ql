/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly approved by security standards.
 * 
 * This analysis focuses on detecting potentially vulnerable padding configurations
 * by excluding only the most secure padding methods (OAEP, KEM, PSS) and flagging
 * all other padding schemes as potential security risks.
 * 
 * Secure padding methods excluded from this detection:
 * - OAEP (Optimal Asymmetric Encryption Padding): Provides semantic security
 *   and is resistant to chosen ciphertext attacks
 * - KEM (Key Encapsulation Mechanism): Modern approach for secure key exchange
 * - PSS (Probabilistic Signature Scheme): Secure for digital signatures
 * 
 * The query targets padding implementations that could be susceptible to various
 * cryptographic attacks when used in asymmetric encryption scenarios, including
 * but not limited to padding oracle attacks, chosen plaintext attacks, and
 * other vulnerabilities that exploit weak padding schemes.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding implementations that use weak or unapproved algorithms
from AsymmetricPadding vulnerablePadding, string algorithmName
where
  // Extract the algorithm name from the padding implementation
  algorithmName = vulnerablePadding.getPaddingName()
  // Exclude only the most secure padding schemes (OAEP, KEM, PSS)
  // All other padding schemes are considered potentially vulnerable
  and not algorithmName in ["OAEP", "KEM", "PSS"]
select vulnerablePadding, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + algorithmName
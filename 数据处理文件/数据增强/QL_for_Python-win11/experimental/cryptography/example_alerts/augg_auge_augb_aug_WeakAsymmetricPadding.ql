/**
 * @name Identification of vulnerable asymmetric cryptographic padding
 * @description
 * This analysis detects the implementation of asymmetric cryptographic padding techniques that are considered
 * weak, unauthorized for secure applications, or possess undetermined security characteristics. For robust
 * cryptographic systems, only particular padding methodologies should be employed. The sanctioned secure
 * asymmetric padding methodologies consist of:
 * - OAEP (Optimal Asymmetric Encryption Padding)
 * - KEM (Key Encapsulation Mechanism)
 * - PSS (Probabilistic Signature Scheme)
 * Implementation of alternative padding methodologies may lead to security weaknesses. This analysis assists
 * in identifying such potentially insecure padding selections by highlighting any asymmetric padding technique
 * that does not belong to the sanctioned secure methodologies.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Locate all asymmetric padding techniques that utilize non-approved secure methodologies
from AsymmetricPadding vulnerablePaddingScheme, string paddingAlgorithmName
where 
  // Phase 1: Retrieve the identifier of the padding algorithm in use
  paddingAlgorithmName = vulnerablePaddingScheme.getPaddingName()
  // Phase 2: Verify that the algorithm is not among the approved secure methodologies
  and not paddingAlgorithmName = "OAEP"  // OAEP is sanctioned for encryption operations
  and not paddingAlgorithmName = "KEM"   // KEM is sanctioned for key encapsulation mechanisms
  and not paddingAlgorithmName = "PSS"   // PSS is sanctioned for digital signature schemes
select vulnerablePaddingScheme, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingAlgorithmName
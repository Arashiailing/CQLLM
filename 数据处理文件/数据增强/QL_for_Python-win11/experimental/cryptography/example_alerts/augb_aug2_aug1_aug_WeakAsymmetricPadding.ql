/**
 * @name Identification of insecure or unverified asymmetric cryptographic padding
 * @description
 * This analysis identifies instances where asymmetric cryptographic padding algorithms
 * are utilized that are either recognized as vulnerable, not sanctioned for security-critical
 * applications, or lack sufficient security evaluation. For asymmetric cryptographic operations,
 * the exclusively endorsed padding methodologies include OAEP (Optimal Asymmetric Encryption Padding),
 * KEM (Key Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme). Implementation of
 * any alternative padding technique may introduce security weaknesses and necessitates replacement
 * with one of the explicitly recommended approaches.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify instances of asymmetric padding algorithms that are not considered secure
from AsymmetricPadding insecurePaddingAlgorithm, string paddingAlgorithmName
where 
  // Extract the name of the padding algorithm being used
  paddingAlgorithmName = insecurePaddingAlgorithm.getPaddingName()
  // Verify that the padding algorithm is not among the approved secure schemes
  and paddingAlgorithmName != "OAEP"
  and paddingAlgorithmName != "KEM"
  and paddingAlgorithmName != "PSS"
select insecurePaddingAlgorithm, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingAlgorithmName
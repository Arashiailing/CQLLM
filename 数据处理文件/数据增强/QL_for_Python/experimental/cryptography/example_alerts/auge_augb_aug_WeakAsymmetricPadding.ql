/**
 * @name Detection of weak or unknown asymmetric padding
 * @description
 * This query identifies the usage of asymmetric cryptographic padding algorithms that are either weak,
 * not approved for secure use, or have unknown security properties. In secure cryptographic implementations,
 * only specific padding schemes should be used. The approved secure asymmetric padding schemes include:
 * - OAEP (Optimal Asymmetric Encryption Padding)
 * - KEM (Key Encapsulation Mechanism)
 * - PSS (Probabilistic Signature Scheme)
 * Using other padding schemes can introduce security vulnerabilities. This query helps detect
 * such potentially insecure padding choices by flagging any asymmetric padding method that is not
 * one of the approved secure schemes.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify all asymmetric padding methods that are not using approved secure schemes
from AsymmetricPadding insecurePaddingMethod, string paddingSchemeName
where 
  // Step 1: Extract the name of the padding algorithm being used
  paddingSchemeName = insecurePaddingMethod.getPaddingName()
  // Step 2: Check if the algorithm is not one of the approved secure schemes
  and not (
    paddingSchemeName = "OAEP" or  // OAEP is approved for encryption operations
    paddingSchemeName = "KEM" or   // KEM is approved for key encapsulation mechanisms
    paddingSchemeName = "PSS"      // PSS is approved for digital signature schemes
  )
select insecurePaddingMethod, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingSchemeName
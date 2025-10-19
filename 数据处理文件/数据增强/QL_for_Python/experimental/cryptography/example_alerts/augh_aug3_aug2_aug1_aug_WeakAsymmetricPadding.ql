/**
 * @name Identification of vulnerable asymmetric cryptographic padding
 * @description
 * Detects asymmetric encryption padding schemes that are either recognized as insecure,
 * not recommended for secure applications, or have undetermined security properties.
 * Only OAEP (Optimal Asymmetric Encryption Padding), KEM (Key Encapsulation Mechanism),
 * and PSS (Probabilistic Signature Scheme) are considered secure for asymmetric cryptography.
 * All alternative padding methods could potentially introduce security weaknesses and
 * should be substituted with approved algorithms.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify vulnerable asymmetric cryptographic padding implementations
from AsymmetricPadding vulnerablePaddingScheme, string schemeName
where 
  // Extract the name of the padding algorithm
  schemeName = vulnerablePaddingScheme.getPaddingName()
  // Check if the padding scheme is not among the approved secure ones
  and schemeName != "OAEP"
  and schemeName != "KEM"
  and schemeName != "PSS"
select vulnerablePaddingScheme, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + schemeName
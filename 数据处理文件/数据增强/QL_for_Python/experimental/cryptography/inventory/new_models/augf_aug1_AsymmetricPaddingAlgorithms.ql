/**
 * @name Asymmetric Encryption Padding Scheme Detection
 * @description Identifies and reports all asymmetric cryptographic padding techniques used in the codebase.
 *              This detection is critical for cryptographic hygiene and quantum readiness assessment.
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python  // Core Python module for code analysis
import experimental.cryptography.Concepts  // Experimental cryptography concepts for cryptographic pattern detection

// Identify all asymmetric padding techniques implemented in the code
from AsymmetricPadding asymmetricPaddingTechnique

// Report each identified asymmetric padding technique with its descriptive name
select asymmetricPaddingTechnique, "Asymmetric padding technique detected: " + asymmetricPaddingTechnique.getPaddingName()
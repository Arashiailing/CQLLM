/**
 * @name CWE CATEGORY: Cryptographic Issues
 * @description nan
 * @kind problem
 * @problem.severity recommendation
 * @security-severity 7.5
 * @precision medium
 * @id py/ElGamal
 */

import python
import semmle.python.ApiGraphs

/*
 * This query identifies the ElGamal cryptographic library.
 *
 * Reference: https://cryptography.io/en/latest/hazmat/primitives/asymmetric/elgamal.html
 */

from API::ModuleImport elgamalLib
where elgamalLib = API::moduleImport("cryptography.hazmat.primitives.asymmetric.elgamal")
select elgamalLib, "The ElGamal encryption algorithm is considered broken."
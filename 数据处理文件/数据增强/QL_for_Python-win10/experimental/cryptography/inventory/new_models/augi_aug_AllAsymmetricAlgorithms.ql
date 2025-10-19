/**
 * @name Comprehensive Asymmetric Algorithm Detection
 * @description Systematically identifies all asymmetric cryptographic implementations (RSA & ECC) 
 *              across supported cryptographic libraries in the codebase.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-asymmetric-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Core language and cryptographic analysis imports
import python
import experimental.cryptography.Concepts

// Retrieve all asymmetric algorithm instances
from AsymmetricAlgorithm cryptoImpl

// Generate detection results with algorithm identification
select cryptoImpl, "Detected asymmetric algorithm: " + cryptoImpl.getName()
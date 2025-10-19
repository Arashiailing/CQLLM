/**
 * @name Cryptographic Signing Algorithm Detection
 * @description Identifies all cryptographic signing algorithm usages across supported libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/signing-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Core Python language analysis framework for code scanning
import python

// Cryptographic concepts and operations analysis module
import experimental.cryptography.Concepts

// Main detection logic for cryptographic signing algorithms
from SigningAlgorithm detectedSigningAlgorithm

// Result generation: Each detected algorithm with identification message
select detectedSigningAlgorithm, "Algorithm detected: " + detectedSigningAlgorithm.getName()
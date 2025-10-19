/**
 * @name Overly permissive file permissions
 * @description Detects file operations that grant excessive read/write access to non-owner users, potentially exposing sensitive data.
 * @kind problem
 * @id py/overly-permissive-file
 * @problem.severity warning
 * @security-severity 7.8
 * @sub-severity high
 * @precision medium
 * @tags external/cwe/cwe-732
 *       security
 */

import python
import semmle.python.ApiGraphs

// Extract world-readable/writable permission bits (lowest 3 bits) from octal mask
bindingset[permValue]
int get_world_perm_bits(int permValue) { 
  result = permValue % 8 
}

// Extract group-readable/writable permission bits (middle 3 bits) from octal mask
bindingset[permValue]
int get_group_perm_bits(int permValue) { 
  result = (permValue / 8) % 8 
}

// Convert permission bits to human-readable access type (read/write)
bindingset[permValue]
string describe_access_type(int permValue) {
  permValue % 4 >= 2 and result = "writable"  // Write bit set (bit 1)
  or
  permValue % 4 < 2 and permValue != 0 and result = "readable"  // Read-only (bit 0 set)
}

// Generate violation description for excessive permissions (world/group access)
bindingset[permValue]
string get_perm_violation_desc(int permValue) {
  result = "world " + describe_access_type(get_world_perm_bits(permValue))  // World access violation
  or
  get_world_perm_bits(permValue) = 0 and result = "group " + describe_access_type(get_group_perm_bits(permValue))  // Group access violation
}

// Identify os.chmod calls with explicit permission mask
predicate is_chmod_op(API::CallNode fileApiCall, string opName, int permMask) {
  fileApiCall = API::moduleImport("os").getMember("chmod").getACall() and
  permMask = fileApiCall.getParameter(1, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  opName = "chmod"
}

// Identify os.open calls with explicit permission mask
predicate is_open_op(API::CallNode fileApiCall, string opName, int permMask) {
  fileApiCall = API::moduleImport("os").getMember("open").getACall() and
  permMask = fileApiCall.getParameter(2, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  opName = "open"
}

// Detect file operations with overly permissive permissions
from API::CallNode fileApiCall, string opName, int permMask, string permViolationDesc
where
  (is_chmod_op(fileApiCall, opName, permMask) or is_open_op(fileApiCall, opName, permMask)) and
  permViolationDesc = get_perm_violation_desc(permMask)
select fileApiCall, "Overly permissive mask in " + opName + " sets file to " + permViolationDesc + "."
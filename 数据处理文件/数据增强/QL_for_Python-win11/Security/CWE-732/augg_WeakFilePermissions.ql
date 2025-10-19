/**
 * @name Overly permissive file permissions
 * @description Detects file operations with excessive read/write permissions for non-owner users
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

// Extracts world-readable/writable permission bits from octal mode
bindingset[modeValue]
int extract_world_permission(int modeValue) { 
  result = modeValue % 8 
}

// Extracts group-readable/writable permission bits from octal mode
bindingset[modeValue]
int extract_group_permission(int modeValue) { 
  result = (modeValue / 8) % 8 
}

// Converts permission bits to human-readable access type
bindingset[permissionBits]
string describe_access(int permissionBits) {
  permissionBits % 4 >= 2 and result = "writable"  // Writeable when last 2 bits >= 2
  or
  permissionBits % 4 < 2 and permissionBits != 0 and result = "readable"  // Readable when non-zero but not writable
}

// Generates description for overly permissive permission components
bindingset[modeValue]
string identify_permissive_permission(int modeValue) {
  result = "world " + describe_access(extract_world_permission(modeValue))  // Prioritize world permissions
  or
  extract_world_permission(modeValue) = 0 and result = "group " + describe_access(extract_group_permission(modeValue))  // Fallback to group permissions
}

// Unified predicate for file permission operations
predicate file_permission_operation(API::CallNode apiCall, string operationType, int permissionMode) {
  (operationType = "chmod" and 
    apiCall = API::moduleImport("os").getMember("chmod").getACall() and
    permissionMode = apiCall.getParameter(1, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue())
  or
  (operationType = "open" and 
    apiCall = API::moduleImport("os").getMember("open").getACall() and
    permissionMode = apiCall.getParameter(2, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue())
}

// Main query detecting overly permissive file operations
from API::CallNode apiCall, string operationType, int permissionMode, string permissionDescription
where
  file_permission_operation(apiCall, operationType, permissionMode) and
  permissionDescription = identify_permissive_permission(permissionMode)
select apiCall, "Overly permissive mask in " + operationType + " sets file to " + permissionDescription + "."
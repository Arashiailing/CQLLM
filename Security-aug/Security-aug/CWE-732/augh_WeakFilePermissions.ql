/**
 * @name Overly permissive file permissions
 * @description Allowing files to be readable or writable by users other than the owner may allow sensitive information to be accessed.
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

// Extract world permission bits (lowest 3 bits) from permission mask
bindingset[permissionValue]
int extract_world_permission(int permissionValue) { 
  result = permissionValue % 8 
}

// Extract group permission bits (middle 3 bits) from permission mask
bindingset[permissionValue]
int extract_group_permission(int permissionValue) { 
  result = (permissionValue / 8) % 8 
}

// Convert permission bits to human-readable access type
bindingset[permissionValue]
string get_access_description(int permissionValue) {
  permissionValue % 4 >= 2 and result = "writable"  // Write permission (bit 1 set)
  or
  permissionValue % 4 < 2 and permissionValue != 0 and result = "readable"  // Read-only permission (bit 0 set)
}

// Generate permission violation description based on world/group access
bindingset[permissionValue]
string get_permission_violation(int permissionValue) {
  result = "world " + get_access_description(extract_world_permission(permissionValue))  // World access violation
  or
  extract_world_permission(permissionValue) = 0 and result = "group " + get_access_description(extract_group_permission(permissionValue))  // Group access violation
}

// Match os.chmod calls with explicit permission mask
predicate is_chmod_call(API::CallNode apiCall, string operationName, int permissionMask) {
  apiCall = API::moduleImport("os").getMember("chmod").getACall() and
  permissionMask = apiCall.getParameter(1, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  operationName = "chmod"
}

// Match os.open calls with explicit permission mask
predicate is_open_call(API::CallNode apiCall, string operationName, int permissionMask) {
  apiCall = API::moduleImport("os").getMember("open").getACall() and
  permissionMask = apiCall.getParameter(2, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  operationName = "open"
}

// Identify file operations with overly permissive permissions
from API::CallNode apiCall, string operationName, int permissionMask, string violationDescription
where
  (is_chmod_call(apiCall, operationName, permissionMask) or is_open_call(apiCall, operationName, permissionMask)) and
  violationDescription = get_permission_violation(permissionMask)
select apiCall, "Overly permissive mask in " + operationName + " sets file to " + violationDescription + "."
/**
 * @name Overly permissive file permissions
 * @description Detects file operations that set overly permissive access rights,
 *              potentially allowing unauthorized users to read or modify sensitive files.
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

// Permission calculation helpers
bindingset[permissionMask]
int calculateWorldPermission(int permissionMask) { 
  result = permissionMask % 8 
}

bindingset[permissionMask]
int calculateGroupPermission(int permissionMask) { 
  result = (permissionMask / 8) % 8 
}

// Permission description helpers
bindingset[permissionMask]
string describeAccessType(int permissionMask) {
  permissionMask % 4 >= 2 and result = "writable"  // Writable if last 2 bits >= 2
  or
  permissionMask % 4 < 2 and permissionMask != 0 and result = "readable"  // Readable if last 2 bits < 2 and non-zero
}

bindingset[permissionMask]
string describePermissivePermission(int permissionMask) {
  // First check world permissions (other users)
  result = "world " + describeAccessType(calculateWorldPermission(permissionMask))
  or
  // If world permissions are 0, check group permissions
  calculateWorldPermission(permissionMask) = 0 and 
  result = "group " + describeAccessType(calculateGroupPermission(permissionMask))
}

// API call detection predicates
predicate detectChmodCall(API::CallNode fileApiCall, string apiFunctionName, int permissionMode) {
  fileApiCall = API::moduleImport("os").getMember("chmod").getACall() and
  permissionMode = fileApiCall.getParameter(1, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  apiFunctionName = "chmod"
}

predicate detectOpenCall(API::CallNode fileApiCall, string apiFunctionName, int permissionMode) {
  fileApiCall = API::moduleImport("os").getMember("open").getACall() and
  permissionMode = fileApiCall.getParameter(2, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  apiFunctionName = "open"
}

// Main query: Find file API calls with overly permissive permissions
from API::CallNode fileApiCall, string apiFunctionName, int permissionMode, string permissionDescription
where
  (detectChmodCall(fileApiCall, apiFunctionName, permissionMode) or 
   detectOpenCall(fileApiCall, apiFunctionName, permissionMode)) and
  permissionDescription = describePermissivePermission(permissionMode)
select fileApiCall, "Overly permissive mask in " + apiFunctionName + " sets file to " + permissionDescription + "."
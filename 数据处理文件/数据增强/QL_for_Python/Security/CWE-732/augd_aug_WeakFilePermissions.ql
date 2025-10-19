/**
 * @name Overly permissive file permissions
 * @description Detects file operations that grant excessive access permissions to non-owner users,
 *              potentially exposing sensitive data to unauthorized access.
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

// Extracts the permissions granted to other users (world) from a permission mask
bindingset[permissionMask]
int getWorldPermission(int permissionMask) { result = permissionMask % 8 }

// Extracts the permissions granted to group members from a permission mask
bindingset[permissionMask]
int getGroupPermission(int permissionMask) { result = (permissionMask / 8) % 8 }

// Converts a permission value to a human-readable access level description
bindingset[permValue]
string getAccessDescription(int permValue) {
  permValue % 4 >= 2 and result = "writable"  // Writable if last 2 bits >= 2
  or
  permValue % 4 < 2 and permValue != 0 and result = "readable"  // Readable if last 2 bits < 2 and non-zero
}

// Creates a description string for overly permissive permission settings
bindingset[permissionMask]
string getPermissionIssueDescription(int permissionMask) {
  result = "world " + getAccessDescription(getWorldPermission(permissionMask))  // Check world permissions first
  or
  getWorldPermission(permissionMask) = 0 and result = "group " + getAccessDescription(getGroupPermission(permissionMask))  // Fallback to group if world is 0
}

// Identifies API calls that set file permissions and extracts the permission values
predicate permissionSettingCall(API::CallNode apiCall, string operationName, int permissionValue) {
  // Handle os.chmod calls
  (
    apiCall = API::moduleImport("os").getMember("chmod").getACall() and
    permissionValue = apiCall.getParameter(1, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
    operationName = "chmod"
  )
  or
  // Handle os.open calls
  (
    apiCall = API::moduleImport("os").getMember("open").getACall() and
    permissionValue = apiCall.getParameter(2, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
    operationName = "open"
  )
}

// Find API calls that set overly permissive file permissions
from API::CallNode apiCall, string operationName, int permissionValue, string issueDescription
where
  permissionSettingCall(apiCall, operationName, permissionValue) and
  issueDescription = getPermissionIssueDescription(permissionValue)
select apiCall, "Overly permissive mask in " + operationName + " sets file to " + issueDescription + "."
/**
 * @name Overly permissive file permissions
 * @description Detects file permission settings that grant excessive access rights to non-owner users
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

/**
 * Extracts the world-accessible permission bits (least significant 3 bits) from a file permission value.
 * @param permissionValue The complete permission value (e.g., 0o777)
 * @return The world permission component (0-7)
 */
bindingset[permissionValue]
int extractWorldPermissionBits(int permissionValue) { 
  result = permissionValue % 8 
}

/**
 * Extracts the group-accessible permission bits (middle 3 bits) from a file permission value.
 * @param permissionValue The complete permission value (e.g., 0o777)
 * @return The group permission component (0-7)
 */
bindingset[permissionValue]
int extractGroupPermissionBits(int permissionValue) { 
  result = (permissionValue / 8) % 8 
}

/**
 * Generates a textual description of permission access levels.
 * @param permissionBits The permission component to describe (0-7)
 * @return "writable" if write access is granted, "readable" if only read access is granted
 */
bindingset[permissionBits]
string describePermissionAccess(int permissionBits) {
  permissionBits % 4 >= 2 and result = "writable"
  or
  permissionBits % 4 < 2 and permissionBits != 0 and result = "readable"
}

/**
 * Identifies overly permissive permission components within a file permission value.
 * @param permissionValue The complete permission value to analyze
 * @return Description of the permissive component (e.g., "world writable")
 */
bindingset[permissionValue]
string identifyPermissiveComponent(int permissionValue) {
  result = "world " + describePermissionAccess(extractWorldPermissionBits(permissionValue))
  or
  extractWorldPermissionBits(permissionValue) = 0 and 
  result = "group " + describePermissionAccess(extractGroupPermissionBits(permissionValue))
}

/**
 * Matches file permission API calls and extracts the permission mode parameter.
 * @param filePermissionCall The API call node
 * @param permissionMethodName The name of the API method ("chmod" or "open")
 * @param permissionMode The permission mode value
 */
predicate matchFilePermissionCall(API::CallNode filePermissionCall, string permissionMethodName, int permissionMode) {
  (permissionMethodName = "chmod" and
   filePermissionCall = API::moduleImport("os").getMember("chmod").getACall() and
   permissionMode = filePermissionCall.getParameter(1, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue())
  or
  (permissionMethodName = "open" and
   filePermissionCall = API::moduleImport("os").getMember("open").getACall() and
   permissionMode = filePermissionCall.getParameter(2, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue())
}

// Identify file permission API calls with overly permissive access modes
from API::CallNode filePermissionCall, string permissionMethodName, int permissionMode, string permissionIssue
where
  matchFilePermissionCall(filePermissionCall, permissionMethodName, permissionMode) and
  permissionIssue = identifyPermissiveComponent(permissionMode)
select filePermissionCall, "Overly permissive mask in " + permissionMethodName + " sets file to " + permissionIssue + "."
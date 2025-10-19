/**
 * @name Overly permissive file permissions
 * @description Detects file permission settings that allow access beyond the owner,
 *              potentially exposing sensitive information to unauthorized users.
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

/**
 * Extracts the "world" (other users) permission bits from a file permission value.
 * The world permission is the least significant octal digit (mod 8).
 */
bindingset[permissionValue]
int world_permission(int permissionValue) { 
  result = permissionValue % 8 
}

/**
 * Extracts the "group" permission bits from a file permission value.
 * The group permission is the second least significant octal digit.
 */
bindingset[permissionValue]
int group_permission(int permissionValue) { 
  result = (permissionValue / 8) % 8 
}

/**
 * Converts a permission value to a descriptive string indicating access level.
 * Returns "writable" if the permission includes write access (bit 1 set),
 * or "readable" if the permission includes read access but not write (bit 2 set).
 */
bindingset[permissionValue]
string access(int permissionValue) {
  permissionValue % 4 >= 2 and result = "writable"
  or
  permissionValue % 4 < 2 and permissionValue != 0 and result = "readable"
}

/**
 * Determines if a permission value is overly permissive and returns a description.
 * Checks world permissions first, then group permissions if world permissions are restrictive.
 */
bindingset[permissionValue]
string permissive_permission(int permissionValue) {
  result = "world " + access(world_permission(permissionValue))
  or
  world_permission(permissionValue) = 0 and result = "group " + access(group_permission(permissionValue))
}

// API call detection predicates

/**
 * Matches calls to os.chmod and extracts the permission mode.
 * os.chmod(path, mode) changes the mode of path to the numeric mode.
 */
predicate chmod_call(API::CallNode apiCall, string functionName, int permissionMode) {
  apiCall = API::moduleImport("os").getMember("chmod").getACall() and
  permissionMode = apiCall.getParameter(1, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  functionName = "chmod"
}

/**
 * Matches calls to os.open and extracts the permission mode.
 * os.open(path, flags, mode) opens the file and sets its permissions to mode.
 */
predicate open_call(API::CallNode apiCall, string functionName, int permissionMode) {
  apiCall = API::moduleImport("os").getMember("open").getACall() and
  permissionMode = apiCall.getParameter(2, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  functionName = "open"
}

// Main query: find overly permissive file permissions

/**
 * Detects file permission settings that are overly permissive.
 * Reports calls to os.chmod or os.open that set permissions allowing
 * read or write access by users other than the owner.
 */
from API::CallNode apiCall, string functionName, int permissionMode, string permissionDesc
where
  (chmod_call(apiCall, functionName, permissionMode) or 
   open_call(apiCall, functionName, permissionMode)) and
  permissionDesc = permissive_permission(permissionMode)
select apiCall, "Overly permissive mask in " + functionName + " sets file to " + permissionDesc + "."
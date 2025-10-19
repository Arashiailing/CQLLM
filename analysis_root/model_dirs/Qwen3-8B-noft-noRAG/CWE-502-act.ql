import python

/**
 * @name Unsafe Deserialization
 * @description Detects deserialization of user-controlled data using pickle.
 */
query unsafe_deserialization() {
  // Find all calls to pickle.loads
  Call callee = python.libraryFunction("pickle.loads")
  
  // Check if the first argument is from an untrusted source
  Argument arg = callee.arguments[0]
  Source src = arg.getSource()
  
  // Filter for sources that are considered user-controlled
  select(src, "Potential unsafe deserialization: pickle.loads with user-controlled input")
}
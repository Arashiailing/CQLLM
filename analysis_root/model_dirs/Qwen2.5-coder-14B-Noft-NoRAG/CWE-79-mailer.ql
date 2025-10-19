import python

from WebRequest req, Expr user_input, Expr output
where
  // Find a web request
  req instanceof WebRequest and
  // Find user input being written directly to a web page
  user_input instanceof UserInput and
  output instanceof WebOutput and
  // Check if the user input is directly written to the output
  user_input = output.getArgument(0)
select req, user_input, output, "Reflected server-side cross-site scripting vulnerability detected."
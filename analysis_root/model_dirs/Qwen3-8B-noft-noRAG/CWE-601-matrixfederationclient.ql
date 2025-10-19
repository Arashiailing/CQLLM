import python

/**
 * @name URL redirection from remote source
 * @description URL redirection based on unvalidated user input may cause redirection to malicious web sites.
 * @id py/matrixfederationclient
 */

// Find instances where user-controlled data is used to construct a URL that triggers a redirect
result = (from Call call
          where call.getMethodName() = "webbrowser.open"
            and exists(Argument arg in call getArguments()
                       where arg.getValue().getSymbol() is Variable var
                         and var.isFromUserInput()))
          union
          (from Call call
           where call.getMethodName() = "requests.get"
             and call.hasParameter("allow_redirects", true)
             and exists(Argument arg in call getArguments()
                        where arg.getValue().getSymbol() is Variable var
                          and var.isFromUserInput()))
          union
          (from Call call
           where call.getMethodName() = "urllib.request.urlopen"
             and exists(Argument arg in call getArguments()
                        where arg.getValue().getSymbol() is Variable var
                          and var.isFromUserInput()))
          union
          (from Expression expr
           where expr instanceof StringConcatenation
             and exists(Argument arg in expr getArguments()
                        where arg.getValue().getSymbol() is Variable var
                          and var.isFromUserInput()
                          and expr.getType().getName() = "str"))

select result
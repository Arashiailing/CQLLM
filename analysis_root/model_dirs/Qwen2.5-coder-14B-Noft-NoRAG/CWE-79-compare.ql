import python

from HttpResponse response, Expr user_input, Expr output_expr
where response.hasBody(output_expr) and
      user_input instanceof HttpRequest and
      output_expr = user_input
select output_expr, "Reflected XSS vulnerability detected: user input is directly written to the response body."
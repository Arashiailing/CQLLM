import python

from FunctionCall call
where call.get_name() = "flask.app.Flask.config" and 
      call.get_argument(0).getValue() = "WTF_CSRF_ENABLED" and 
      call.get_argument(1).getValue() = "False" or
      call.get_name() = "flask.csrf.CSRFProtect" and 
      call.get_argument(0).getValue() = "False" or
      call.get_name() = "django.views.decorators.csrf.csrf_exempt"
select call, "CSRF protection is disabled or weakened in this code"
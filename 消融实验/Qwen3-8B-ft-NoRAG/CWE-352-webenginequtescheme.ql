import python
from python.File import File
from python.Call import Call
from python.Decorator import Decorator
from python.Function import Function

// Check for CSRF protection disabled in settings (Django)
select File where File.path matches "settings.py" and 
  File.text matches "CSRF_COOKIE_SECURE = False" or 
  File.text matches "CSRF_PROTECTION_DISABLED = True"

// Check for csrf_exempt decorator (Django)
select Function where Decorator.name is "csrf_exempt" and Decorator.appliesTo(Function)

// Check for missing csrf_token in forms (Flask)
select Call where Call.name is "csrf_token" and 
  Call is not in a form context
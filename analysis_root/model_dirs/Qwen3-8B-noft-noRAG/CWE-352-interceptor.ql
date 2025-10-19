import python

/**
 * Detects potential CSRF vulnerabilities by checking for:
 * 1. Missing CSRF middleware in Django applications
 * 2. Use of csrf_exempt decorator in Django views
 * 3. Disabled CSRF protection through configuration settings
 */
@name("CSRF protection weakened or disabled")
@description("Disabling or weakening CSRF protection may make the application vulnerable to a Cross-Site Request Forgery (CSRF) attack.")
@id("py/interceptor")

from 
  Importer I,
  Module M, 
  Call C, 
  MethodOrFunctionDeclaration D,
  Literal L
  
where 
  (I.getModule() = M and 
   M.getName() = "django.conf.settings" and 
   M.hasMember("MIDDLEWARE") and 
   not (M.getMembers().has("CsrfViewMiddleware") and 
        M.getMiddles().contains("django.middleware.csrf.CsrfViewMiddleware"))) 

or 
  (D.getCalls().has(C) and 
   C.getMethodName() = "csrf_exempt" and 
   D.isDecorator())

or 
  (L.getValue() = "False" and 
   L.getVariable() = "csrfmiddleware" and 
   L.getFile().getName().matches("settings.py")) 

select 
  M, 
  "Potential CSRF protection weakness detected"
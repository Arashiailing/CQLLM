/**
 * @name Find new subclasses to model
 * @id py/meta/find-subclasses-to-model
 * @kind table
 */

import python
import semmle.python.dataflow.new.DataFlow
private import semmle.python.ApiGraphs
import semmle.python.frameworks.internal.SubclassFinder::NotExposed
private import semmle.python.frameworks.Flask
private import semmle.python.frameworks.FastApi
private import semmle.python.frameworks.Django
private import semmle.python.frameworks.Tornado
private import semmle.python.frameworks.Stdlib
private import semmle.python.frameworks.Requests
private import semmle.python.frameworks.Starlette
private import semmle.python.frameworks.ClickhouseDriver
private import semmle.python.frameworks.Aiohttp
private import semmle.python.frameworks.Fabric
private import semmle.python.frameworks.Httpx
private import semmle.python.frameworks.Invoke
private import semmle.python.frameworks.MarkupSafe
private import semmle.python.frameworks.Multidict
private import semmle.python.frameworks.Pycurl
private import semmle.python.frameworks.RestFramework
private import semmle.python.frameworks.SqlAlchemy
private import semmle.python.frameworks.Tornado
private import semmle.python.frameworks.Urllib3
private import semmle.python.frameworks.Pydantic
private import semmle.python.frameworks.Peewee
private import semmle.python.frameworks.Aioch
private import semmle.python.frameworks.Lxml
import semmle.python.frameworks.data.internal.ApiGraphModelsExtensions as Extensions

// 定义一个类，用于查找 Flask View 类的子类
class FlaskViewClasses extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  FlaskViewClasses() { this = "flask.View~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() { result = Flask::Views::View::subclassRef() }
}

// 定义一个类，用于查找 Flask MethodView 类的子类
class FlaskMethodViewClasses extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  FlaskMethodViewClasses() { this = "flask.MethodView~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() { result = Flask::Views::MethodView::subclassRef() }

  // 重写方法，返回父类
  override FindSubclassesSpec getSuperClass() { result instanceof FlaskViewClasses }

  // 重写方法，返回完全限定名
  override string getFullyQualifiedName() { result = "flask.views.MethodView" }
}

// 定义一个类，用于查找 FastApiRouter 类的子类
class FastApiRouter extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  FastApiRouter() { this = "fastapi.APIRouter~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() { result = FastApi::ApiRouter::cls() }
}

// 定义一个类，用于查找 Django Form 类的子类
class DjangoForms extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  DjangoForms() { this = "django.forms.BaseForm~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = any(Django::Forms::Form::ModeledSubclass subclass)
  }
}

// 定义一个类，用于查找 Django View 类的子类
class DjangoView extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  DjangoView() { this = "Django.Views.View~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = any(Django::Views::View::ModeledSubclass subclass)
  }
}

// 定义一个类，用于查找 Django Field 类的子类
class DjangoField extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  DjangoField() { this = "Django.Forms.Field~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = any(Django::Forms::Field::ModeledSubclass subclass)
  }
}

// 定义一个类，用于查找 Django Model 类的子类
class DjangoModel extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  DjangoModel() { this = "Django.db.models.Model~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DB::Models::Model::subclassRef()
  }
}

// 定义一个类，用于查找 Tornado RequestHandler 类的子类
class TornadoRequestHandler extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  TornadoRequestHandler() { this = "tornado.web.RequestHandler~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = Tornado::TornadoModule::Web::RequestHandler::subclassRef()
  }
}

// 定义一个类，用于查找 WSGIServer 类的子类
class WSGIServer extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  WSGIServer() { this = "wsgiref.simple_server.WSGIServer~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = StdlibPrivate::WsgirefSimpleServer::subclassRef()
  }
}

// 定义一个类，用于查找 Stdlib BaseHttpRequestHandler 类的子类
class StdlibBaseHttpRequestHandler extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  StdlibBaseHttpRequestHandler() { this = "http.server.BaseHTTPRequestHandler~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = StdlibPrivate::BaseHttpRequestHandler::subclassRef()
  }
}

// 定义一个类，用于查找 Stdlib CgiFieldStorage 类的子类
class StdlibCgiFieldStorage extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  StdlibCgiFieldStorage() { this = "cgi.FieldStorage~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = StdlibPrivate::Cgi::FieldStorage::subclassRef()
  }
}

// 定义一个类，用于查找 Django HttpResponse 类的子类
class DjangoHttpResponse extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  DjangoHttpResponse() { this = "django.http.response.HttpResponse~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponse::classRef()
  }
}

// 定义一个类，用于查找 Django HttpResponseRedirect 类的子类
class DjangoHttpResponseRedirect extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  DjangoHttpResponseRedirect() { this = "django.http.response.HttpResponseRedirect~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponseRedirect::classRef()
  }

  // 重写方法，返回父类
  override FindSubclassesSpec getSuperClass() { result instanceof DjangoHttpResponse }

  // 重写方法，返回完全限定名
  override string getFullyQualifiedName() { result = "django.http.response.HttpResponseRedirect" }
}

// 定义一个类，用于查找 Django HttpResponsePermanentRedirect 类的子类
class DjangoHttpResponsePermanentRedirect extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  DjangoHttpResponsePermanentRedirect() { this = "django.http.response.HttpResponsePermanentRedirect~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponsePermanentRedirect::classRef()
  }

  // 重写方法，返回父类
  override FindSubclassesSpec getSuperClass() { result instanceof DjangoHttpResponse }

  // 重写方法，返回完全限定名
  override string getFullyQualifiedName() { result = "django.http.response.HttpResponsePermanentRedirect" }
}

// 定义一个类，用于查找 Django HttpResponseNotModified 类的子类
class DjangoHttpResponseNotModified extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  DjangoHttpResponseNotModified() { this = "django.http.response.HttpResponseNotModified~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponseNotModified::classRef()
  }

  // 重写方法，返回父类
  override FindSubclassesSpec getSuperClass() { result instanceof DjangoHttpResponse }

  // 重写方法，返回完全限定名
  override string getFullyQualifiedName() { result = "django.http.response.HttpResponseNotModified" }
}

// 定义一个类，用于查找 Django HttpResponseBadRequest 类的子类
class DjangoHttpResponseBadRequest extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  DjangoHttpResponseBadRequest() { this = "django.http.response.HttpResponseBadRequest~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponseBadRequest::classRef()
  }

  // 重写方法，返回父类
  override FindSubclassesSpec getSuperClass() { result instanceof DjangoHttpResponse }

  // 重写方法，返回完全限定名
  override string getFullyQualifiedName() { result = "django.http.response.HttpResponseBadRequest" }
}

// 定义一个类，用于查找 Django HttpResponseNotFound 类的子类
class DjangoHttpResponseNotFound extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  DjangoHttpResponseNotFound() { this = "django.http.response.HttpResponseNotFound~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponseNotFound::classRef()
  }

  // 重写方法，返回父类
  override FindSubclassesSpec getSuperClass() { result instanceof DjangoHttpResponse }

  // 重写方法，返回完全限定名
  override string getFullyQualifiedName() { result = "django.http.response.HttpResponseNotFound" }
}

// 定义一个类，用于查找 Django HttpResponseForbidden 类的子类
class DjangoHttpResponseForbidden extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  DjangoHttpResponseForbidden() { this = "django.http.response.HttpResponseForbidden~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponseForbidden::classRef()
  }

  // 重写方法，返回父类
  override FindSubclassesSpec getSuperClass() { result instanceof DjangoHttpResponse }

  // 重写方法，返回完全限定名
  override string getFullyQualifiedName() { result = "django.http.response.HttpResponseForbidden" }
}

// 定义一个类，用于查找 Django HttpResponseNotAllowed 类的子类
class DjangoHttpResponseNotAllowed extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  DjangoHttpResponseNotAllowed() { this = "django.http.response.HttpResponseNotAllowed~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponseNotAllowed::classRef()
  }

  // 重写方法，返回父类
  override FindSubclassesSpec getSuperClass() { result instanceof DjangoHttpResponse }

  // 重写方法，返回完全限定名
  override string getFullyQualifiedName() { result = "django.http.response.HttpResponseNotAllowed" }
}

// 定义一个类，用于查找 Django HttpResponseGone 类的子类
class DjangoHttpResponseGone extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  DjangoHttpResponseGone() { this = "django.http.response.HttpResponseGone~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponseGone::classRef()
  }

  // 重写方法，返回父类
  override FindSubclassesSpec getSuperClass() { result instanceof DjangoHttpResponse }

  // 重写方法，返回完全限定名
  override string getFullyQualifiedName() { result = "django.http.response.HttpResponseGone" }
}

// 定义一个类，用于查找 Django HttpResponseServerError 类的子类
class DjangoHttpResponseServerError extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  DjangoHttpResponseServerError() { this = "django.http.response.HttpResponseServerError~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::HttpResponseServerError::classRef()
  }

  // 重写方法，返回父类
  override FindSubclassesSpec getSuperClass() { result instanceof DjangoHttpResponse }

  // 重写方法，返回完全限定名
  override string getFullyQualifiedName() { result = "django.http.response.HttpResponseServerError" }
}

// 定义一个类，用于查找 Django HttpResponseJsonResponse 类的子类
class DjangoHttpResponseJsonResponse extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  DjangoHttpResponseJsonResponse() { this = "django.http.response.JsonResponse~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::JsonResponse::classRef()
  }

  // 重写方法，返回父类
  override FindSubclassesSpec getSuperClass() { result instanceof DjangoHttpResponse }

  // 重写方法，返回完全限定名
  override string getFullyQualifiedName() { result = "django.http.response.JsonResponse" }
}

// 定义一个类，用于查找 Django StreamingHttpResponse 类的子类
class DjangoHttpResponseStreamingResponse extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  DjangoHttpResponseStreamingResponse() { this = "django.http.response.StreamingHttpResponse~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::StreamingHttpResponse::classRef()
  }
}

// 定义一个类，用于查找 Django FileResponse 类的子类
class DjangoHttpResponseFileResponse extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  DjangoHttpResponseFileResponse() { this = "django.http.response.FileResponse~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() {
    result = PrivateDjango::DjangoImpl::DjangoHttp::Response::FileResponse::classRef()
  }

  // 重写方法，返回父类
  override FindSubclassesSpec getSuperClass() { result instanceof DjangoHttpResponseStreamingResponse }

  // 重写方法，返回完全限定名
  override string getFullyQualifiedName() { result = "django.http.response.FileResponse" }
}

// 定义一个类，用于查找 Flask Response 类的子类
class FlaskResponse extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  FlaskResponse() { this = "flask.Response~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() { result = Flask::Response::classRef() }
}

// 定义一个类，用于查找 Requests Response 类的子类
class RequestsResponse extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  RequestsResponse() { this = "requests.models.Response~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() { result = Requests::Response::classRef() }
}

// 定义一个类，用于查找 HTTPClient HTTPResponse 类的子类
class HttpClientHttpResponse extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  HttpClientHttpResponse() { this = "http.client.HTTPResponse~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() { result = StdlibPrivate::HttpResponse::classRef() }
}

// 定义一个类，用于查找 Starlette WebSocket 类的子类
class StarletteWebsocket extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  StarletteWebsocket() { this = "starlette.websockets.WebSocket~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() { result = Starlette::WebSocket::classRef() }
}

// 定义一个类，用于查找 Starlette URL 类的子类
class StarletteUrl extends FindSubclassesSpec {
  // 构造函数，指定要查找的子类类型
  StarletteUrl() { this = "starlette.requests.URL~Subclass" }

  // 重写方法，返回已经建模的类
  override API::Node getAlreadyModeledClass() { result = Starlette::Url::classRef() }
}

// 定义一个类，用于查找 Clickhouse Driver Client 类的子类
class ClickhouseClient extends FindSubclassesSpec {

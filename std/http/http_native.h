// Meteor HTTP Native Library
// 底层 HTTP 服务器和客户端的 C 实现

#ifndef METEOR_HTTP_NATIVE_H
#define METEOR_HTTP_NATIVE_H

#ifdef _WIN32
    #define EXPORT __declspec(dllexport)
    #include <winsock2.h>
    #include <ws2tcpip.h>
    #include <windows.h>
    #pragma comment(lib, "ws2_32.lib")
    #pragma comment(lib, "winhttp.lib")
    typedef int socklen_t;
    #define close closesocket
#else
    #define EXPORT
    #include <sys/socket.h>
    #include <netinet/in.h>
    #include <arpa/inet.h>
    #include <unistd.h>
    #include <netdb.h>
#endif

#include <stdint.h>
#include <stddef.h>

// ============================================================================
// Constants
// ============================================================================

#define HTTP_MAX_HEADERS 64
#define HTTP_MAX_HEADER_SIZE 8192
#define HTTP_MAX_BODY_SIZE 10485760  // 10MB
#define HTTP_DEFAULT_TIMEOUT 30000   // 30 seconds

// HTTP Methods
#define HTTP_METHOD_GET     0
#define HTTP_METHOD_POST    1
#define HTTP_METHOD_PUT     2
#define HTTP_METHOD_DELETE  3
#define HTTP_METHOD_PATCH   4
#define HTTP_METHOD_HEAD    5
#define HTTP_METHOD_OPTIONS 6

// HTTP Status Codes
#define HTTP_STATUS_OK                  200
#define HTTP_STATUS_CREATED             201
#define HTTP_STATUS_NO_CONTENT          204
#define HTTP_STATUS_MOVED_PERMANENTLY   301
#define HTTP_STATUS_FOUND               302
#define HTTP_STATUS_NOT_MODIFIED        304
#define HTTP_STATUS_BAD_REQUEST         400
#define HTTP_STATUS_UNAUTHORIZED        401
#define HTTP_STATUS_FORBIDDEN           403
#define HTTP_STATUS_NOT_FOUND           404
#define HTTP_STATUS_METHOD_NOT_ALLOWED  405
#define HTTP_STATUS_INTERNAL_ERROR      500
#define HTTP_STATUS_NOT_IMPLEMENTED     501
#define HTTP_STATUS_BAD_GATEWAY         502
#define HTTP_STATUS_SERVICE_UNAVAILABLE 503

// ============================================================================
// Types
// ============================================================================

typedef void* MeteorHttpServer;
typedef void* MeteorHttpClient;
typedef void* MeteorHttpConnection;

// Header structure
typedef struct {
    const char* name;
    const char* value;
} MeteorHttpHeader;

// Request structure
typedef struct {
    int method;
    const char* path;
    const char* query;
    const char* body;
    size_t body_length;
    MeteorHttpHeader headers[HTTP_MAX_HEADERS];
    int header_count;
    const char* remote_addr;
    int remote_port;
} MeteorHttpRequest;

// Response structure
typedef struct {
    int status_code;
    MeteorHttpHeader headers[HTTP_MAX_HEADERS];
    int header_count;
    char* body;
    size_t body_length;
} MeteorHttpResponse;

// Request handler callback
typedef void (*MeteorRequestHandler)(MeteorHttpRequest* req, MeteorHttpResponse* res, void* userdata);

// ============================================================================
// Server Functions
// ============================================================================

// Create a new HTTP server
EXPORT MeteorHttpServer meteor_http_server_create(void);

// Set server options
EXPORT int meteor_http_server_set_host(MeteorHttpServer server, const char* host);
EXPORT int meteor_http_server_set_port(MeteorHttpServer server, int port);
EXPORT int meteor_http_server_set_static_dir(MeteorHttpServer server, const char* dir);

// Route registration
EXPORT int meteor_http_server_route(MeteorHttpServer server, int method, const char* pattern, 
                                    MeteorRequestHandler handler, void* userdata);

// Start server (blocking)
EXPORT int meteor_http_server_listen(MeteorHttpServer server);

// Low-level primitives for Meteor implementation
EXPORT int meteor_http_server_bind(MeteorHttpServer server);
EXPORT MeteorHttpConnection meteor_http_server_accept(MeteorHttpServer server);
EXPORT MeteorHttpRequest* meteor_http_connection_read_request(MeteorHttpConnection conn);
EXPORT int meteor_http_connection_send_response(MeteorHttpConnection conn, MeteorHttpResponse* res);
EXPORT void meteor_http_connection_close(MeteorHttpConnection conn);

// Start server (non-blocking)
EXPORT int meteor_http_server_start(MeteorHttpServer server);

// Stop server
EXPORT int meteor_http_server_stop(MeteorHttpServer server);

// Destroy server
EXPORT void meteor_http_server_destroy(MeteorHttpServer server);

// ============================================================================
// Client Functions
// ============================================================================

// Create HTTP client
EXPORT MeteorHttpClient meteor_http_client_create(void);

// Set client options
EXPORT int meteor_http_client_set_timeout(MeteorHttpClient client, int timeout_ms);
EXPORT int meteor_http_client_set_header(MeteorHttpClient client, const char* name, const char* value);

// Make HTTP request
EXPORT MeteorHttpResponse* meteor_http_client_request(
    MeteorHttpClient client,
    int method,
    const char* url,
    const char* body,
    size_t body_length
);

// Free response
EXPORT void meteor_http_response_free(MeteorHttpResponse* response);

// Destroy client
EXPORT void meteor_http_client_destroy(MeteorHttpClient client);

// ============================================================================
// Convenience Functions
// ============================================================================

// Quick GET request
EXPORT MeteorHttpResponse* meteor_http_get(const char* url);

// Quick POST request
EXPORT MeteorHttpResponse* meteor_http_post(const char* url, const char* body, size_t body_length);

// Response helpers
EXPORT void meteor_http_response_init(MeteorHttpResponse* res);
EXPORT int meteor_http_response_set_status(MeteorHttpResponse* res, int status_code);
EXPORT int meteor_http_response_set_header(MeteorHttpResponse* res, const char* name, const char* value);
EXPORT int meteor_http_response_set_body(MeteorHttpResponse* res, const char* body, size_t length);
EXPORT int meteor_http_response_set_json(MeteorHttpResponse* res, const char* json);
EXPORT int meteor_http_response_set_html(MeteorHttpResponse* res, const char* html);
EXPORT int meteor_http_response_set_text(MeteorHttpResponse* res, const char* text);

// URL encoding/decoding
EXPORT char* meteor_url_encode(const char* str);
EXPORT char* meteor_url_decode(const char* str);

// Get status message
EXPORT const char* meteor_http_status_message(int status_code);

// Parse query string
EXPORT int meteor_parse_query_string(const char* query, MeteorHttpHeader* params, int max_params);

// ============================================================================
// Request Accessors (Added for FFI)
// ============================================================================

EXPORT int meteor_request_get_method(MeteorHttpRequest* req);
EXPORT const char* meteor_request_get_path(MeteorHttpRequest* req);
EXPORT const char* meteor_request_get_query(MeteorHttpRequest* req);
EXPORT const char* meteor_request_get_body(MeteorHttpRequest* req);
EXPORT const char* meteor_request_get_header(MeteorHttpRequest* req, const char* name);
EXPORT const char* meteor_request_get_param(MeteorHttpRequest* req, const char* name); // For path params if supported

EXPORT int meteor_request_get_header_count(MeteorHttpRequest* req);
EXPORT const char* meteor_request_get_header_name_at(MeteorHttpRequest* req, int index);
EXPORT const char* meteor_request_get_header_value_at(MeteorHttpRequest* req, int index);

EXPORT MeteorHttpResponse* meteor_http_response_create();


#endif // METEOR_HTTP_NATIVE_H

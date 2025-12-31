// Meteor HTTP Server Library - Minimal Implementation
// A basic HTTP server library for Meteor programming language

#ifndef HTTP_SERVER_H
#define HTTP_SERVER_H

#ifdef _WIN32
    #define EXPORT __declspec(dllexport)
    #include <winsock2.h>
    #include <ws2tcpip.h>
    #pragma comment(lib, "ws2_32.lib")
#else
    #define EXPORT
    #include <sys/socket.h>
    #include <netinet/in.h>
    #include <arpa/inet.h>
    #include <unistd.h>
#endif

#include <stdint.h>

// ============================================================================
// Types
// ============================================================================

// Server handle (opaque pointer)
typedef void* HttpServer;

// Request structure (simplified)
typedef struct {
    const char* method;      // GET, POST, etc.
    const char* path;        // Request path
    const char* body;        // Request body (for POST)
    int body_length;         // Body length
} HttpRequest;

// Response structure
typedef struct {
    int status_code;         // HTTP status code (200, 404, etc.)
    const char* content_type; // Content-Type header
    const char* body;        // Response body
    int body_length;         // Body length
} HttpResponse;

// Route handler function type
typedef void (*RouteHandler)(HttpRequest* req, HttpResponse* res);

// ============================================================================
// Server Functions
// ============================================================================

// Create a new HTTP server instance
// Returns: Server handle (NULL on failure)
EXPORT HttpServer http_server_create(void);

// Start listening on a port
// Returns: 0 on success, -1 on failure
EXPORT int http_server_listen(HttpServer server, int port);

// Accept a single connection and handle it (blocking)
// Returns: 0 on success, -1 on failure
EXPORT int http_server_accept_one(HttpServer server);

// Stop the server and release resources
EXPORT void http_server_stop(HttpServer server);

// Get the server's file descriptor/socket handle
EXPORT int http_server_get_fd(HttpServer server);

// Check if server is running
EXPORT int http_server_is_running(HttpServer server);

// ============================================================================
// Request/Response Helpers
// ============================================================================

// Set response status code
EXPORT void http_response_set_status(HttpResponse* res, int status_code);

// Set response content type
EXPORT void http_response_set_content_type(HttpResponse* res, const char* content_type);

// Set response body
EXPORT void http_response_set_body(HttpResponse* res, const char* body, int length);

// Send a simple text response
EXPORT void http_send_text(int client_fd, int status_code, const char* body);

// Send a simple HTML response
EXPORT void http_send_html(int client_fd, int status_code, const char* body);

// Send a JSON response
EXPORT void http_send_json(int client_fd, int status_code, const char* body);

// ============================================================================
// Utility Functions
// ============================================================================

// Parse HTTP request from raw data
// Returns: 0 on success, -1 on failure
EXPORT int http_parse_request(const char* raw_data, int data_length, HttpRequest* req);

// Get HTTP status message for a status code
EXPORT const char* http_status_message(int status_code);

// Simple URL decode
EXPORT int http_url_decode(const char* src, char* dst, int dst_len);

// Get query parameter value (returns NULL if not found)
EXPORT const char* http_get_query_param(const char* path, const char* param_name);

// ============================================================================
// Simple API (uses global server instance)
// ============================================================================

// Create and start server (simple API)
EXPORT int http_listen(int port);

// Accept one request (simple API)
EXPORT int http_accept(void);

// Stop server (simple API)
EXPORT void http_stop(void);

// Check if server is running (simple API)
EXPORT int http_is_running(void);

// Get server port (simple API)
EXPORT int http_get_port(void);

#endif // HTTP_SERVER_H


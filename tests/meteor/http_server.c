// Meteor HTTP Server Library - C Implementation
// A basic HTTP server for Meteor programming language

#include "http_server.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
    #include <winsock2.h>
    #include <ws2tcpip.h>
    typedef int socklen_t;
    #define close closesocket
#else
    #include <sys/socket.h>
    #include <netinet/in.h>
    #include <arpa/inet.h>
    #include <unistd.h>
#endif

// ============================================================================
// Internal Server Structure
// ============================================================================

typedef struct {
    int socket_fd;
    int port;
    int is_running;
    struct sockaddr_in address;
} InternalServer;

// Buffer sizes
#define REQUEST_BUFFER_SIZE 4096
#define RESPONSE_BUFFER_SIZE 8192

// Static buffers for request parsing
static char s_method_buffer[16];
static char s_path_buffer[1024];
static char s_body_buffer[4096];

// ============================================================================
// Platform-specific initialization
// ============================================================================

#ifdef _WIN32
static int wsa_initialized = 0;

static int init_winsock(void) {
    if (!wsa_initialized) {
        WSADATA wsa_data;
        if (WSAStartup(MAKEWORD(2, 2), &wsa_data) != 0) {
            return -1;
        }
        wsa_initialized = 1;
    }
    return 0;
}

static void cleanup_winsock(void) {
    if (wsa_initialized) {
        WSACleanup();
        wsa_initialized = 0;
    }
}
#endif

// ============================================================================
// Server Functions Implementation
// ============================================================================

EXPORT HttpServer http_server_create(void) {
#ifdef _WIN32
    if (init_winsock() != 0) {
        return NULL;
    }
#endif

    InternalServer* server = (InternalServer*)malloc(sizeof(InternalServer));
    if (!server) {
        return NULL;
    }

    memset(server, 0, sizeof(InternalServer));
    server->socket_fd = -1;
    server->is_running = 0;

    return (HttpServer)server;
}

EXPORT int http_server_listen(HttpServer handle, int port) {
    InternalServer* server = (InternalServer*)handle;
    if (!server) return -1;

    // Create socket
    server->socket_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server->socket_fd < 0) {
        return -1;
    }

    // Set socket options
    int opt = 1;
#ifdef _WIN32
    setsockopt(server->socket_fd, SOL_SOCKET, SO_REUSEADDR, (const char*)&opt, sizeof(opt));
#else
    setsockopt(server->socket_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
#endif

    // Setup address structure
    server->address.sin_family = AF_INET;
    server->address.sin_addr.s_addr = INADDR_ANY;
    server->address.sin_port = htons(port);

    // Bind
    if (bind(server->socket_fd, (struct sockaddr*)&server->address, sizeof(server->address)) < 0) {
        close(server->socket_fd);
        server->socket_fd = -1;
        return -1;
    }

    // Listen
    if (listen(server->socket_fd, 10) < 0) {
        close(server->socket_fd);
        server->socket_fd = -1;
        return -1;
    }

    server->port = port;
    server->is_running = 1;

    return 0;
}

EXPORT int http_server_accept_one(HttpServer handle) {
    InternalServer* server = (InternalServer*)handle;
    if (!server || server->socket_fd < 0 || !server->is_running) {
        return -1;
    }

    struct sockaddr_in client_addr;
    socklen_t client_len = sizeof(client_addr);

    int client_fd = accept(server->socket_fd, (struct sockaddr*)&client_addr, &client_len);
    if (client_fd < 0) {
        return -1;
    }

    // Read request
    char buffer[REQUEST_BUFFER_SIZE];
    memset(buffer, 0, sizeof(buffer));
    int bytes_read = recv(client_fd, buffer, sizeof(buffer) - 1, 0);
    
    if (bytes_read > 0) {
        // Parse request
        HttpRequest req;
        if (http_parse_request(buffer, bytes_read, &req) == 0) {
            // Default response: simple echo of path
            char response_body[1024];
            snprintf(response_body, sizeof(response_body), 
                "{\n  \"message\": \"Hello from Meteor HTTP Server!\",\n  \"method\": \"%s\",\n  \"path\": \"%s\"\n}",
                req.method, req.path);
            http_send_json(client_fd, 200, response_body);
        } else {
            http_send_text(client_fd, 400, "Bad Request");
        }
    }

    close(client_fd);
    return 0;
}

EXPORT void http_server_stop(HttpServer handle) {
    InternalServer* server = (InternalServer*)handle;
    if (!server) return;

    if (server->socket_fd >= 0) {
        close(server->socket_fd);
    }
    server->is_running = 0;
    free(server);

#ifdef _WIN32
    cleanup_winsock();
#endif
}

EXPORT int http_server_get_fd(HttpServer handle) {
    InternalServer* server = (InternalServer*)handle;
    if (!server) return -1;
    return server->socket_fd;
}

EXPORT int http_server_is_running(HttpServer handle) {
    InternalServer* server = (InternalServer*)handle;
    if (!server) return 0;
    return server->is_running;
}

// ============================================================================
// Response Helpers Implementation
// ============================================================================

EXPORT void http_response_set_status(HttpResponse* res, int status_code) {
    if (res) {
        res->status_code = status_code;
    }
}

EXPORT void http_response_set_content_type(HttpResponse* res, const char* content_type) {
    if (res) {
        res->content_type = content_type;
    }
}

EXPORT void http_response_set_body(HttpResponse* res, const char* body, int length) {
    if (res) {
        res->body = body;
        res->body_length = length;
    }
}

static void send_http_response(int client_fd, int status_code, const char* content_type, const char* body) {
    char response[RESPONSE_BUFFER_SIZE];
    int body_len = body ? (int)strlen(body) : 0;
    
    int header_len = snprintf(response, sizeof(response),
        "HTTP/1.1 %d %s\r\n"
        "Content-Type: %s\r\n"
        "Content-Length: %d\r\n"
        "Connection: close\r\n"
        "\r\n",
        status_code, http_status_message(status_code),
        content_type,
        body_len);
    
    // Send header
    send(client_fd, response, header_len, 0);
    
    // Send body
    if (body && body_len > 0) {
        send(client_fd, body, body_len, 0);
    }
}

EXPORT void http_send_text(int client_fd, int status_code, const char* body) {
    send_http_response(client_fd, status_code, "text/plain; charset=utf-8", body);
}

EXPORT void http_send_html(int client_fd, int status_code, const char* body) {
    send_http_response(client_fd, status_code, "text/html; charset=utf-8", body);
}

EXPORT void http_send_json(int client_fd, int status_code, const char* body) {
    send_http_response(client_fd, status_code, "application/json; charset=utf-8", body);
}

// ============================================================================
// Utility Functions Implementation
// ============================================================================

EXPORT int http_parse_request(const char* raw_data, int data_length, HttpRequest* req) {
    if (!raw_data || !req || data_length <= 0) {
        return -1;
    }

    memset(req, 0, sizeof(HttpRequest));

    // Parse first line: METHOD PATH HTTP/1.1
    const char* line_end = strstr(raw_data, "\r\n");
    if (!line_end) {
        return -1;
    }

    // Extract method
    const char* p = raw_data;
    int i = 0;
    while (p < line_end && *p != ' ' && i < 15) {
        s_method_buffer[i++] = *p++;
    }
    s_method_buffer[i] = '\0';
    req->method = s_method_buffer;

    // Skip space
    while (p < line_end && *p == ' ') p++;

    // Extract path
    i = 0;
    while (p < line_end && *p != ' ' && i < 1023) {
        s_path_buffer[i++] = *p++;
    }
    s_path_buffer[i] = '\0';
    req->path = s_path_buffer;

    // Find body (after double CRLF)
    const char* body_start = strstr(raw_data, "\r\n\r\n");
    if (body_start) {
        body_start += 4;
        int body_len = data_length - (body_start - raw_data);
        if (body_len > 0 && body_len < 4095) {
            memcpy(s_body_buffer, body_start, body_len);
            s_body_buffer[body_len] = '\0';
            req->body = s_body_buffer;
            req->body_length = body_len;
        }
    }

    return 0;
}

EXPORT const char* http_status_message(int status_code) {
    switch (status_code) {
        case 200: return "OK";
        case 201: return "Created";
        case 204: return "No Content";
        case 301: return "Moved Permanently";
        case 302: return "Found";
        case 304: return "Not Modified";
        case 400: return "Bad Request";
        case 401: return "Unauthorized";
        case 403: return "Forbidden";
        case 404: return "Not Found";
        case 405: return "Method Not Allowed";
        case 500: return "Internal Server Error";
        case 502: return "Bad Gateway";
        case 503: return "Service Unavailable";
        default: return "Unknown";
    }
}

EXPORT int http_url_decode(const char* src, char* dst, int dst_len) {
    if (!src || !dst || dst_len <= 0) {
        return -1;
    }

    int i = 0, j = 0;
    while (src[i] && j < dst_len - 1) {
        if (src[i] == '%' && src[i+1] && src[i+2]) {
            char hex[3] = { src[i+1], src[i+2], 0 };
            dst[j++] = (char)strtol(hex, NULL, 16);
            i += 3;
        } else if (src[i] == '+') {
            dst[j++] = ' ';
            i++;
        } else {
            dst[j++] = src[i++];
        }
    }
    dst[j] = '\0';
    return j;
}

EXPORT const char* http_get_query_param(const char* path, const char* param_name) {
    if (!path || !param_name) {
        return NULL;
    }

    // Find query string start
    const char* query = strchr(path, '?');
    if (!query) {
        return NULL;
    }
    query++; // Skip '?'

    static char value_buffer[256];
    int param_len = (int)strlen(param_name);

    while (*query) {
        if (strncmp(query, param_name, param_len) == 0 && query[param_len] == '=') {
            // Found parameter
            const char* val_start = query + param_len + 1;
            const char* val_end = val_start;
            while (*val_end && *val_end != '&') val_end++;
            
            int val_len = val_end - val_start;
            if (val_len >= 255) val_len = 255;
            
            memcpy(value_buffer, val_start, val_len);
            value_buffer[val_len] = '\0';
            return value_buffer;
        }

        // Move to next parameter
        while (*query && *query != '&') query++;
        if (*query == '&') query++;
    }

    return NULL;
}

// ============================================================================
// Simple standalone functions for Meteor FFI
// ============================================================================

// Global server instance for simple API
static InternalServer* g_server = NULL;

// Create and start server (simple API)
EXPORT int http_listen(int port) {
    if (g_server) {
        http_server_stop(g_server);
    }
    
    g_server = http_server_create();
    if (!g_server) {
        return -1;
    }
    
    return http_server_listen(g_server, port);
}

// Accept one request (simple API)
EXPORT int http_accept() {
    if (!g_server) {
        return -1;
    }
    return http_server_accept_one(g_server);
}

// Stop server (simple API)
EXPORT void http_stop() {
    if (g_server) {
        http_server_stop(g_server);
        g_server = NULL;
    }
}

// Check if server is running (simple API)
EXPORT int http_is_running() {
    if (!g_server) {
        return 0;
    }
    return http_server_is_running(g_server);
}

// Get server port (simple API)
EXPORT int http_get_port() {
    if (!g_server) {
        return -1;
    }
    return ((InternalServer*)g_server)->port;
}

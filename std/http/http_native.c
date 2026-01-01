// Meteor HTTP Native Library - Implementation
// 底层 HTTP 服务器和客户端的 C 实现

#include "http_native.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

// ============================================================================
// Internal Structures
// ============================================================================

typedef struct {
#ifdef _WIN32
    SOCKET socket_fd;
#else
    int socket_fd;
#endif
    char host[256];
    int port;
    int is_running;
    char static_dir[1024];
    struct {
        int method;
        char pattern[256];
        MeteorRequestHandler handler;
        void* userdata;
    } routes[256];
    int route_count;
} InternalServer;

typedef struct {
#ifdef _WIN32
    SOCKET socket_fd;
#else
    int socket_fd;
#endif
    struct sockaddr_in addr;
} InternalConnection;

typedef struct {
    int timeout_ms;
    MeteorHttpHeader default_headers[HTTP_MAX_HEADERS];
    int default_header_count;
} InternalClient;

// ============================================================================
// Platform Initialization
// ============================================================================

#ifdef _WIN32
static int wsa_initialized = 0;
static int utf8_initialized = 0;

static void init_utf8_console(void) {
    if (!utf8_initialized) {
        // Set console output to UTF-8 for emoji support
        SetConsoleOutputCP(65001);
        utf8_initialized = 1;
    }
}

static int init_winsock(void) {
    if (!wsa_initialized) {
        init_utf8_console();
        WSADATA wsa_data;
        if (WSAStartup(MAKEWORD(2, 2), &wsa_data) != 0) {
            return -1;
        }
        wsa_initialized = 1;
    }
    return 0;
}
#endif

// ============================================================================
// Helper Functions
// ============================================================================

EXPORT const char* meteor_http_status_message(int status_code) {
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
        case 501: return "Not Implemented";
        case 502: return "Bad Gateway";
        case 503: return "Service Unavailable";
        default: return "Unknown";
    }
}

EXPORT char* meteor_url_encode(const char* str) {
    if (!str) return NULL;
    
    size_t len = strlen(str);
    char* encoded = (char*)malloc(len * 3 + 1);
    if (!encoded) return NULL;
    
    char* p = encoded;
    for (size_t i = 0; i < len; i++) {
        char c = str[i];
        if (isalnum(c) || c == '-' || c == '_' || c == '.' || c == '~') {
            *p++ = c;
        } else if (c == ' ') {
            *p++ = '+';
        } else {
            sprintf(p, "%%%02X", (unsigned char)c);
            p += 3;
        }
    }
    *p = '\0';
    return encoded;
}

EXPORT char* meteor_url_decode(const char* str) {
    if (!str) return NULL;
    
    size_t len = strlen(str);
    char* decoded = (char*)malloc(len + 1);
    if (!decoded) return NULL;
    
    char* p = decoded;
    for (size_t i = 0; i < len; i++) {
        if (str[i] == '%' && i + 2 < len) {
            int hex;
            sscanf(str + i + 1, "%2x", &hex);
            *p++ = (char)hex;
            i += 2;
        } else if (str[i] == '+') {
            *p++ = ' ';
        } else {
            *p++ = str[i];
        }
    }
    *p = '\0';
    return decoded;
}

EXPORT int meteor_parse_query_string(const char* query, MeteorHttpHeader* params, int max_params) {
    if (!query || !params) return 0;
    
    int count = 0;
    char* copy = strdup(query);
    char* token = strtok(copy, "&");
    
    while (token && count < max_params) {
        char* eq = strchr(token, '=');
        if (eq) {
            *eq = '\0';
            params[count].name = strdup(token);
            params[count].value = meteor_url_decode(eq + 1);
            count++;
        }
        token = strtok(NULL, "&");
    }
    
    free(copy);
    return count;
}

// ============================================================================
// Response Helpers
// ============================================================================

EXPORT void meteor_http_response_init(MeteorHttpResponse* res) {
    if (!res) return;
    memset(res, 0, sizeof(MeteorHttpResponse));
    res->status_code = 200;
}

EXPORT int meteor_http_response_set_status(MeteorHttpResponse* res, int status_code) {
    if (!res) return -1;
    res->status_code = status_code;
    return 0;
}

EXPORT int meteor_http_response_set_header(MeteorHttpResponse* res, const char* name, const char* value) {
    if (!res || res->header_count >= HTTP_MAX_HEADERS) return -1;
    res->headers[res->header_count].name = strdup(name);
    res->headers[res->header_count].value = strdup(value);
    res->header_count++;
    return 0;
}

EXPORT int meteor_http_response_set_body(MeteorHttpResponse* res, const char* body, size_t length) {
    if (!res) return -1;
    if (res->body) free(res->body);
    res->body = (char*)malloc(length + 1);
    if (!res->body) return -1;
    memcpy(res->body, body, length);
    res->body[length] = '\0';
    res->body_length = length;
    return 0;
}

EXPORT int meteor_http_response_set_json(MeteorHttpResponse* res, const char* json) {
    meteor_http_response_set_header(res, "Content-Type", "application/json");
    return meteor_http_response_set_body(res, json, strlen(json));
}

EXPORT int meteor_http_response_set_html(MeteorHttpResponse* res, const char* html) {
    meteor_http_response_set_header(res, "Content-Type", "text/html; charset=utf-8");
    return meteor_http_response_set_body(res, html, strlen(html));
}

EXPORT int meteor_http_response_set_text(MeteorHttpResponse* res, const char* text) {
    meteor_http_response_set_header(res, "Content-Type", "text/plain; charset=utf-8");
    return meteor_http_response_set_body(res, text, strlen(text));
}

// ============================================================================
// Server Implementation
// ============================================================================

EXPORT MeteorHttpServer meteor_http_server_create(void) {
#ifdef _WIN32
    if (init_winsock() != 0) {
        return NULL;
    }
#endif

    InternalServer* server = (InternalServer*)malloc(sizeof(InternalServer));
    if (!server) return NULL;
    
    memset(server, 0, sizeof(InternalServer));
    strcpy(server->host, "127.0.0.1");
    server->port = 8080;
    server->socket_fd = -1;
    
    return (MeteorHttpServer)server;
}

EXPORT int meteor_http_server_set_host(MeteorHttpServer handle, const char* host) {
    InternalServer* server = (InternalServer*)handle;
    if (!server || !host) return -1;
    // Debug: print incoming host string bytes
    printf("DEBUG set_host: ");
    for (int i = 0; host[i] && i < 20; i++) {
        printf("%02x ", (unsigned char)host[i]);
    }
    printf(" -> '%s'\n", host);
    fflush(stdout);
    memset(server->host, 0, sizeof(server->host));
    strncpy(server->host, host, sizeof(server->host) - 1);
    server->host[sizeof(server->host) - 1] = '\0';
    return 0;
}

EXPORT int meteor_http_server_set_port(MeteorHttpServer handle, int port) {
    InternalServer* server = (InternalServer*)handle;
    if (!server || port <= 0 || port > 65535) return -1;
    server->port = port;
    return 0;
}

EXPORT int meteor_http_server_set_static_dir(MeteorHttpServer handle, const char* dir) {
    InternalServer* server = (InternalServer*)handle;
    if (!server) return -1;
    strncpy(server->static_dir, dir ? dir : "", sizeof(server->static_dir) - 1);
    return 0;
}

EXPORT int meteor_http_server_route(MeteorHttpServer handle, int method, const char* pattern,
                                    MeteorRequestHandler handler, void* userdata) {
    InternalServer* server = (InternalServer*)handle;
    if (!server || server->route_count >= 256) return -1;
    
    int idx = server->route_count++;
    server->routes[idx].method = method;
    strncpy(server->routes[idx].pattern, pattern, sizeof(server->routes[idx].pattern) - 1);
    server->routes[idx].handler = handler;
    server->routes[idx].userdata = userdata;
    
    return 0;
}

static int parse_request(const char* data, size_t len, MeteorHttpRequest* req) {
    // Parse HTTP request line: METHOD PATH HTTP/1.1
    const char* line_end = strstr(data, "\r\n");
    if (!line_end) return -1;
    
    // Parse method
    static char method_buf[16];
    const char* space = strchr(data, ' ');
    if (!space) return -1;
    size_t method_len = space - data;
    memcpy(method_buf, data, method_len);
    method_buf[method_len] = '\0';
    
    if (strcmp(method_buf, "GET") == 0) req->method = HTTP_METHOD_GET;
    else if (strcmp(method_buf, "POST") == 0) req->method = HTTP_METHOD_POST;
    else if (strcmp(method_buf, "PUT") == 0) req->method = HTTP_METHOD_PUT;
    else if (strcmp(method_buf, "DELETE") == 0) req->method = HTTP_METHOD_DELETE;
    else if (strcmp(method_buf, "PATCH") == 0) req->method = HTTP_METHOD_PATCH;
    else if (strcmp(method_buf, "HEAD") == 0) req->method = HTTP_METHOD_HEAD;
    else if (strcmp(method_buf, "OPTIONS") == 0) req->method = HTTP_METHOD_OPTIONS;
    
    // Parse path
    const char* path_start = space + 1;
    const char* path_end = strchr(path_start, ' ');
    if (!path_end) return -1;
    
    static char path_buf[2048];
    size_t path_len = path_end - path_start;
    memcpy(path_buf, path_start, path_len);
    path_buf[path_len] = '\0';
    
    // Separate query string
    char* query = strchr(path_buf, '?');
    if (query) {
        *query = '\0';
        req->query = strdup(query + 1);
    } else {
        req->query = "";
    }
    req->path = strdup(path_buf);
    
    // Parse headers
    const char* header_start = line_end + 2;
    req->header_count = 0;
    
    while (header_start < data + len) {
        const char* header_end = strstr(header_start, "\r\n");
        if (!header_end) break;
        if (header_end == header_start) {
            // Empty line - body follows
            req->body = header_start + 2;
            req->body_length = len - (req->body - data);
            break;
        }
        
        const char* colon = strchr(header_start, ':');
        if (colon && colon < header_end && req->header_count < HTTP_MAX_HEADERS) {
            static char name_buf[256], value_buf[1024];
            size_t name_len = colon - header_start;
            memcpy(name_buf, header_start, name_len);
            name_buf[name_len] = '\0';
            
            const char* value_start = colon + 1;
            while (*value_start == ' ') value_start++;
            size_t value_len = header_end - value_start;
            memcpy(value_buf, value_start, value_len);
            value_buf[value_len] = '\0';
            
            req->headers[req->header_count].name = strdup(name_buf);
            req->headers[req->header_count].value = strdup(value_buf);
            req->header_count++;
        }
        
        header_start = header_end + 2;
    }
    
    return 0;
}

static void send_response(int client_fd, MeteorHttpResponse* res) {
    char header_buf[4096];
    int header_len = snprintf(header_buf, sizeof(header_buf),
        "HTTP/1.1 %d %s\r\n"
        "Connection: close\r\n"
        "Content-Length: %zu\r\n",
        res->status_code,
        meteor_http_status_message(res->status_code),
        res->body_length
    );
    
    for (int i = 0; i < res->header_count; i++) {
        header_len += snprintf(header_buf + header_len, sizeof(header_buf) - header_len,
            "%s: %s\r\n", res->headers[i].name, res->headers[i].value);
    }
    
    header_len += snprintf(header_buf + header_len, sizeof(header_buf) - header_len, "\r\n");
    
    send(client_fd, header_buf, header_len, 0);
    if (res->body && res->body_length > 0) {
        send(client_fd, res->body, res->body_length, 0);
    }
}

static int match_route(const char* pattern, const char* path) {
    // Simple pattern matching (supports :param for path parameters)
    while (*pattern && *path) {
        if (*pattern == ':') {
            // Skip parameter name
            while (*pattern && *pattern != '/') pattern++;
            // Skip path segment
            while (*path && *path != '/') path++;
        } else if (*pattern != *path) {
            return 0;
        } else {
            pattern++;
            path++;
        }
    }
    return *pattern == '\0' && *path == '\0';
}

EXPORT int meteor_http_server_listen(MeteorHttpServer handle) {
    InternalServer* server = (InternalServer*)handle;
    if (!server) return -1;
    
    // Create socket
    server->socket_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server->socket_fd < 0) {
        perror("socket");
        return -1;
    }
    
    // Set socket options
    int opt = 1;
    setsockopt(server->socket_fd, SOL_SOCKET, SO_REUSEADDR, (char*)&opt, sizeof(opt));
    
    // Bind
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(server->port);
    inet_pton(AF_INET, server->host, &addr.sin_addr);
    
    if (bind(server->socket_fd, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        perror("bind");
        close(server->socket_fd);
        return -1;
    }
    
    // Listen
    if (listen(server->socket_fd, 10) < 0) {
        perror("listen");
        close(server->socket_fd);
        return -1;
    }
    
    printf("🚀 Meteor HTTP Server listening on http://%s:%d\n", server->host, server->port);
    fflush(stdout);
    server->is_running = 1;
    
    // Accept loop
    while (server->is_running) {
        struct sockaddr_in client_addr;
        socklen_t client_len = sizeof(client_addr);
        int client_fd = accept(server->socket_fd, (struct sockaddr*)&client_addr, &client_len);
        
        if (client_fd < 0) {
            if (server->is_running) perror("accept");
            continue;
        }
        
        // Read request
        char buffer[HTTP_MAX_HEADER_SIZE];
        int received = recv(client_fd, buffer, sizeof(buffer) - 1, 0);
        if (received <= 0) {
            close(client_fd);
            continue;
        }
        buffer[received] = '\0';
        
        // Parse request
        MeteorHttpRequest req;
        memset(&req, 0, sizeof(req));
        char remote_addr[64];
        inet_ntop(AF_INET, &client_addr.sin_addr, remote_addr, sizeof(remote_addr));
        req.remote_addr = remote_addr;
        req.remote_port = ntohs(client_addr.sin_port);
        
        if (parse_request(buffer, received, &req) < 0) {
            close(client_fd);
            continue;
        }
        
        // Find matching route
        MeteorHttpResponse res;
        meteor_http_response_init(&res);
        int handled = 0;
        
        for (int i = 0; i < server->route_count; i++) {
            if (server->routes[i].method == req.method &&
                match_route(server->routes[i].pattern, req.path)) {
                server->routes[i].handler(&req, &res, server->routes[i].userdata);
                handled = 1;
                break;
            }
        }
        
        if (!handled) {
            res.status_code = 404;
            meteor_http_response_set_html(&res, "<h1>404 Not Found</h1>");
        }
        
        // Send response
        send_response(client_fd, &res);
        
        // Cleanup
        close(client_fd);
        if (res.body) free(res.body);
    }
    
    return 0;
}

EXPORT int meteor_http_server_stop(MeteorHttpServer handle) {
    InternalServer* server = (InternalServer*)handle;
    if (!server) return -1;
    
    server->is_running = 0;
    if (server->socket_fd >= 0) {
        close(server->socket_fd);
        server->socket_fd = -1;
    }
    return 0;
}

EXPORT void meteor_http_server_destroy(MeteorHttpServer handle) {
    InternalServer* server = (InternalServer*)handle;
    if (!server) return;
    
    meteor_http_server_stop(handle);
    free(server);
}

// ============================================================================
// Client Implementation
// ============================================================================

EXPORT MeteorHttpClient meteor_http_client_create(void) {
#ifdef _WIN32
    if (init_winsock() != 0) {
        return NULL;
    }
#endif

    InternalClient* client = (InternalClient*)malloc(sizeof(InternalClient));
    if (!client) return NULL;
    
    memset(client, 0, sizeof(InternalClient));
    client->timeout_ms = HTTP_DEFAULT_TIMEOUT;
    
    return (MeteorHttpClient)client;
}

EXPORT int meteor_http_client_set_timeout(MeteorHttpClient handle, int timeout_ms) {
    InternalClient* client = (InternalClient*)handle;
    if (!client) return -1;
    client->timeout_ms = timeout_ms;
    return 0;
}

EXPORT int meteor_http_client_set_header(MeteorHttpClient handle, const char* name, const char* value) {
    InternalClient* client = (InternalClient*)handle;
    if (!client || client->default_header_count >= HTTP_MAX_HEADERS) return -1;
    client->default_headers[client->default_header_count].name = strdup(name);
    client->default_headers[client->default_header_count].value = strdup(value);
    client->default_header_count++;
    return 0;
}

static int parse_url(const char* url, char* host, int* port, char* path) {
    // Skip protocol
    const char* start = url;
    if (strncmp(url, "http://", 7) == 0) {
        start = url + 7;
        *port = 80;
    } else if (strncmp(url, "https://", 8) == 0) {
        start = url + 8;
        *port = 443;
    } else {
        *port = 80;
    }
    
    // Find path
    const char* path_start = strchr(start, '/');
    if (path_start) {
        strcpy(path, path_start);
        size_t host_len = path_start - start;
        memcpy(host, start, host_len);
        host[host_len] = '\0';
    } else {
        strcpy(path, "/");
        strcpy(host, start);
    }
    
    // Check for port
    char* port_str = strchr(host, ':');
    if (port_str) {
        *port_str = '\0';
        *port = atoi(port_str + 1);
    }
    
    return 0;
}

EXPORT MeteorHttpResponse* meteor_http_client_request(
    MeteorHttpClient handle,
    int method,
    const char* url,
    const char* body,
    size_t body_length
) {
    InternalClient* client = (InternalClient*)handle;
    if (!url) return NULL;
    
    // Parse URL
    char host[256], path[2048];
    int port;
    parse_url(url, host, &port, path);
    
    // Resolve host
    struct hostent* he = gethostbyname(host);
    if (!he) return NULL;
    
    // Create socket
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) return NULL;
    
    // Set timeout
    struct timeval tv;
    tv.tv_sec = client ? client->timeout_ms / 1000 : HTTP_DEFAULT_TIMEOUT / 1000;
    tv.tv_usec = (client ? client->timeout_ms : HTTP_DEFAULT_TIMEOUT) % 1000 * 1000;
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, (char*)&tv, sizeof(tv));
    
    // Connect
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    memcpy(&addr.sin_addr, he->h_addr, he->h_length);
    
    if (connect(sock, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        close(sock);
        return NULL;
    }
    
    // Build request
    const char* method_str;
    switch (method) {
        case HTTP_METHOD_GET: method_str = "GET"; break;
        case HTTP_METHOD_POST: method_str = "POST"; break;
        case HTTP_METHOD_PUT: method_str = "PUT"; break;
        case HTTP_METHOD_DELETE: method_str = "DELETE"; break;
        case HTTP_METHOD_PATCH: method_str = "PATCH"; break;
        case HTTP_METHOD_HEAD: method_str = "HEAD"; break;
        case HTTP_METHOD_OPTIONS: method_str = "OPTIONS"; break;
        default: method_str = "GET";
    }
    
    char request[4096];
    int req_len = snprintf(request, sizeof(request),
        "%s %s HTTP/1.1\r\n"
        "Host: %s\r\n"
        "Connection: close\r\n"
        "Content-Length: %zu\r\n",
        method_str, path, host, body_length
    );
    
    // Add default headers
    if (client) {
        for (int i = 0; i < client->default_header_count; i++) {
            req_len += snprintf(request + req_len, sizeof(request) - req_len,
                "%s: %s\r\n", client->default_headers[i].name, client->default_headers[i].value);
        }
    }
    
    req_len += snprintf(request + req_len, sizeof(request) - req_len, "\r\n");
    
    // Send request
    send(sock, request, req_len, 0);
    if (body && body_length > 0) {
        send(sock, body, body_length, 0);
    }
    
    // Read response
    char buffer[HTTP_MAX_HEADER_SIZE + HTTP_MAX_BODY_SIZE];
    size_t total = 0;
    int received;
    
    while ((received = recv(sock, buffer + total, sizeof(buffer) - total - 1, 0)) > 0) {
        total += received;
    }
    buffer[total] = '\0';
    close(sock);
    
    // Parse response
    MeteorHttpResponse* res = (MeteorHttpResponse*)malloc(sizeof(MeteorHttpResponse));
    if (!res) return NULL;
    meteor_http_response_init(res);
    
    // Parse status line
    if (sscanf(buffer, "HTTP/1.%*d %d", &res->status_code) != 1) {
        free(res);
        return NULL;
    }
    
    // Find body
    const char* body_start = strstr(buffer, "\r\n\r\n");
    if (body_start) {
        body_start += 4;
        size_t response_body_len = total - (body_start - buffer);
        res->body = (char*)malloc(response_body_len + 1);
        if (res->body) {
            memcpy(res->body, body_start, response_body_len);
            res->body[response_body_len] = '\0';
            res->body_length = response_body_len;
        }
    }
    
    return res;
}

EXPORT void meteor_http_response_free(MeteorHttpResponse* response) {
    if (!response) return;
    if (response->body) free(response->body);
    for (int i = 0; i < response->header_count; i++) {
        // Note: Headers use strdup, need to free
    }
    free(response);
}

EXPORT void meteor_http_client_destroy(MeteorHttpClient handle) {
    InternalClient* client = (InternalClient*)handle;
    if (!client) return;
    free(client);
}

// ============================================================================
// Convenience Functions
// ============================================================================

EXPORT MeteorHttpResponse* meteor_http_get(const char* url) {
    return meteor_http_client_request(NULL, HTTP_METHOD_GET, url, NULL, 0);
}

EXPORT MeteorHttpResponse* meteor_http_post(const char* url, const char* body, size_t body_length) {
    return meteor_http_client_request(NULL, HTTP_METHOD_POST, url, body, body_length);
}

// ============================================================================
// Request Accessors
// ============================================================================

EXPORT int meteor_request_get_method(MeteorHttpRequest* req) {
    return req ? req->method : 0;
}

EXPORT const char* meteor_request_get_path(MeteorHttpRequest* req) {
    return req ? req->path : "";
}

EXPORT const char* meteor_request_get_query(MeteorHttpRequest* req) {
    return req ? req->query : "";
}

EXPORT const char* meteor_request_get_body(MeteorHttpRequest* req) {
    return req ? req->body : "";
}

EXPORT const char* meteor_request_get_header(MeteorHttpRequest* req, const char* name) {
    if (!req || !name) return "";
    for (int i = 0; i < req->header_count; i++) {
        // Simple case-insensitive comparison
        const char *s1 = req->headers[i].name;
        const char *s2 = name;
        while (*s1 && *s2) {
            if (tolower((unsigned char)*s1) != tolower((unsigned char)*s2)) break;
            s1++; s2++;
        }
        if (*s1 == 0 && *s2 == 0) return req->headers[i].value;
    }
    return "";
}

EXPORT const char* meteor_request_get_param(MeteorHttpRequest* req, const char* name) {
    // Not implemented in native layer yet
    return "";
}

EXPORT int meteor_request_get_header_count(MeteorHttpRequest* req) {
    return req ? req->header_count : 0;
}

EXPORT const char* meteor_request_get_header_name_at(MeteorHttpRequest* req, int index) {
    if (!req || index < 0 || index >= req->header_count) return "";
    return req->headers[index].name;
}

EXPORT const char* meteor_request_get_header_value_at(MeteorHttpRequest* req, int index) {
    if (!req || index < 0 || index >= req->header_count) return "";
    return req->headers[index].value;
}

EXPORT MeteorHttpResponse* meteor_http_response_create() {
    MeteorHttpResponse* res = (MeteorHttpResponse*)malloc(sizeof(MeteorHttpResponse));
    if (res) meteor_http_response_init(res);
    return res;
}


// ============================================================================
// Low-level Server Primitives
// ============================================================================

EXPORT int meteor_http_server_bind(MeteorHttpServer handle) {
    InternalServer* server = (InternalServer*)handle;
    if (!server) return -1;
    
    // Create socket
    server->socket_fd = socket(AF_INET, SOCK_STREAM, 0);
#ifdef _WIN32
    if (server->socket_fd == INVALID_SOCKET) {
        fprintf(stderr, "socket error: %d\n", WSAGetLastError());
        return -1;
    }
#else
    if (server->socket_fd < 0) {
        perror("socket");
        return -1;
    }
#endif
    
    // Set socket options
    int opt = 1;
    setsockopt(server->socket_fd, SOL_SOCKET, SO_REUSEADDR, (char*)&opt, sizeof(opt));
    
    // Bind
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(server->port);
    inet_pton(AF_INET, server->host, &addr.sin_addr);
    
    if (bind(server->socket_fd, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
#ifdef _WIN32
        fprintf(stderr, "bind error: %d\n", WSAGetLastError());
#else
        perror("bind");
#endif
        close(server->socket_fd);
        return -1;
    }
    
    // Listen
    if (listen(server->socket_fd, 10) < 0) {
#ifdef _WIN32
        fprintf(stderr, "listen error: %d\n", WSAGetLastError());
#else
        perror("listen");
#endif
        close(server->socket_fd);
        return -1;
    }
    
    printf("🚀 Meteor HTTP Server listening on http://%s:%d\n", server->host, server->port);
    fflush(stdout);
    server->is_running = 1;
    return 0;
}

EXPORT MeteorHttpConnection meteor_http_server_accept(MeteorHttpServer handle) {
    InternalServer* server = (InternalServer*)handle;
    if (!server || !server->is_running) return NULL;
    
    struct sockaddr_in client_addr;
    socklen_t client_len = sizeof(client_addr);
    int client_fd = accept(server->socket_fd, (struct sockaddr*)&client_addr, &client_len);
    
    if (client_fd < 0) return NULL;
    
    InternalConnection* conn = (InternalConnection*)malloc(sizeof(InternalConnection));
    if (!conn) {
        close(client_fd);
        return NULL;
    }
    conn->socket_fd = client_fd;
    conn->addr = client_addr;
    return (MeteorHttpConnection)conn;
}

EXPORT MeteorHttpRequest* meteor_http_connection_read_request(MeteorHttpConnection handle) {
    InternalConnection* conn = (InternalConnection*)handle;
    if (!conn) return NULL;
    
    char buffer[HTTP_MAX_HEADER_SIZE];
    int received = recv(conn->socket_fd, buffer, sizeof(buffer) - 1, 0);
    if (received <= 0) return NULL;
    buffer[received] = '\0';
    
    MeteorHttpRequest* req = (MeteorHttpRequest*)malloc(sizeof(MeteorHttpRequest));
    if (!req) return NULL;
    memset(req, 0, sizeof(MeteorHttpRequest));
    
    char remote_addr[64];
    inet_ntop(AF_INET, &conn->addr.sin_addr, remote_addr, sizeof(remote_addr));
    req->remote_addr = strdup(remote_addr);
    req->remote_port = ntohs(conn->addr.sin_port);
    
    if (parse_request(buffer, received, req) < 0) {
        free(req);
        return NULL;
    }
    
    return req;
}

EXPORT int meteor_http_connection_send_response(MeteorHttpConnection handle, MeteorHttpResponse* res) {
    InternalConnection* conn = (InternalConnection*)handle;
    if (!conn || !res) return -1;
    
    send_response(conn->socket_fd, res);
    return 0;
}

EXPORT void meteor_http_connection_close(MeteorHttpConnection handle) {
    InternalConnection* conn = (InternalConnection*)handle;
    if (!conn) return;
    
    close(conn->socket_fd);
    free(conn);
}



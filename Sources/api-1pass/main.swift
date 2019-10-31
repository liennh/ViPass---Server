import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

import PerfectRequestLogger


// Adding the location for the log file
RequestLogFile.location = "./webLog.log"

// Create HTTP server.
let server = HTTPServer()

// Setup logging
let logger = RequestLogger()
// Set the log marker for the timer when the request is incoming
server.setRequestFilters([(logger, .high)])
// Finish the log trracking when the request is complete and ready to be returned to client
server.setResponseFilters([(logger, .low)])


// Register routes and handlers
let JSONRoutes = makeJSONRoutes("/api/v1/")

// Add the routes to the server.
server.addRoutes(JSONRoutes)


// Set a listen port of 8181
server.serverPort = 8181

// Set a document root.
// This is optional. If you do not want to serve static content then do not set this.
// Setting the document root will automatically add a static file handler for the route /**
//server.documentRoot = "./webroot"

// Gather command line options and further configure the server.
// Run the server with --help to see the list of supported arguments.
// Command line arguments will supplant any of the values set above.
configureServer(server)

do {
    // Launch the HTTP server.
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}

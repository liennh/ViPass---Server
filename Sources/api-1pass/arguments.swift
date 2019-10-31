//
//  arguments.swift
//  api-1pass
//
//  Created by Ngo Lien on 5/14/18.
//
// Refer to https://github.com/PerfectExamples/PerfectArcade/blob/master/Sources/arguments.swift

import PerfectHTTPServer
import PerfectLib

#if os(Linux)
import SwiftGlibc
#else
import Darwin
#endif

// Check all command line arguments used to configure the server.
// These are all optional and you can remove or add arguments as required.
func configureServer(_ server: HTTPServer) {
    
    var sslCert: String?
    var sslKey: String?
    
    var args = CommandLine.arguments
    
    func argFirst() -> String {
        guard let frst = args.first else {
            print("Argument requires value.")
            exit(-1)
        }
        return frst
    }
    
    let validArgs = [
        "--sslcert": {
            args.removeFirst()
            sslCert = argFirst()
        },
        "--sslkey": {
            args.removeFirst()
            sslKey = argFirst()
        },
        "--port": {
            args.removeFirst()
            server.serverPort = UInt16(argFirst()) ?? 8181
        },
        "--address": {
            args.removeFirst()
            server.serverAddress = argFirst()
        },
        "--root": {
            args.removeFirst()
            server.documentRoot = argFirst()
        },
        "--name": {
            args.removeFirst()
            server.serverName = argFirst()
        },
        "--runas": {
            args.removeFirst()
            server.runAsUser = argFirst()
        },
        "--help": {
            print("Usage: \(CommandLine.arguments.first!) [--port listen_port] [--address listen_address] [--name server_name] [--root root_path] [--sslcert cert_path --sslkey key_path] [--runas user_name]")
            exit(0)
        }]
    
    while args.count > 0 {
        if let closure = validArgs[args.first!.lowercased()] {
            closure()
        }
        args.removeFirst()
    }
    
    if sslCert != nil || sslKey != nil {
        if sslCert == nil || sslKey == nil {
            print("Error: if either --sslcert or --sslkey is provided then both --sslcert and --sslkey must be provided.")
            exit(-1)
        }
        if !File(sslCert!).exists || !File(sslKey!).exists {
            print("Error: --sslcert or --sslkey file did not exist.")
            exit(-1)
        }
        server.ssl = (sslCert: sslCert!, sslKey: sslKey!)
    }
}

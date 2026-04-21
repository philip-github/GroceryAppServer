import Vapor
import Fluent
import FluentPostgresDriver
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    try app.databases.use(.postgres(configuration: .init(hostname: Environment.get("DB_HOST_NAME") ?? "",
                                                         username: Environment.get("DB_USER_NAME") ?? "",
                                                         database: Environment.get("DB_NAME") ?? "",
                                                         tls: .prefer(.init(configuration: .clientDefault)))), as: .psql)
    
    // register migrations
    app.migrations.add(CreateUserTableMigration())
    app.migrations.add(CreateGroceryCategoryTableMigration())
    app.migrations.add(CreateGroceryItemTableMigration())
    
    // register controllers
    try app.register(collection: UserController())
    try app.register(collection: GroceryController())
    
    // setup JWT hash algorithm
    await app.jwt.keys.add(hmac: .init(stringLiteral: Environment.get("JWT_SIGN_KEY") ?? ""), digestAlgorithm: .sha256)
    
    // register routes
    try routes(app)
}


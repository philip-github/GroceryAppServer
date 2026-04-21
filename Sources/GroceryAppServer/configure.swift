import Vapor
import Fluent
import FluentPostgresDriver
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    try app.databases.use(.postgres(configuration: .init(hostname: "localhost",
                                                         port: 5432,
                                                         username: "postgres",
                                                         database: "grocerydb",
                                                         tls: .prefer(.init(configuration: .clientDefault)))), as: .psql)
    
    // register migrations
    app.migrations.add(CreateUserTableMigration())
    app.migrations.add(CreateGroceryCategoryTableMigration())
    app.migrations.add(CreateGroceryItemTableMigration())
    
    // register controllers
    try app.register(collection: UserController())
    try app.register(collection: GroceryController())
    
    // setup JWT hash algorithm
    await app.jwt.keys.add(hmac: .init(stringLiteral: "my-secret-key"), digestAlgorithm: .sha256)
    
    // register routes
    try routes(app)
}


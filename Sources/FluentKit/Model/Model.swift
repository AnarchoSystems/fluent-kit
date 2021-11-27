public protocol Model: AnyModel, DbView where ViewBase == Self {
    associatedtype IDValue: Codable, Hashable
    var id: IDValue? { get set }
}

extension Model {
    
    public func injected(from base: Self) -> Self {
        base
    }
    
    public var customFields: [DatabaseQuery.Field] {
        []
    }
    
    public static func query(on database: Database) -> QueryBuilder<Self> {
        .init(database: database)
    }

    public static func find(
        _ id: Self.IDValue?,
        on database: Database
    ) -> EventLoopFuture<Self?> {
        guard let id = id else {
            return database.eventLoop.makeSucceededFuture(nil)
        }
        return Self.query(on: database)
            .filter(\._$id == id)
            .first()
    }

    public func requireID() throws -> IDValue {
        guard let id = self.id else {
            throw FluentError.idRequired
        }
        return id
    }

    public var _$id: ID<IDValue> {
        self.anyID as! ID<IDValue>
    }
}

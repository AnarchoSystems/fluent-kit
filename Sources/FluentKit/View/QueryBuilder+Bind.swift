
// MARK: DBView

public protocol DbView {
    
    associatedtype ViewBase : FluentKit.Model
    init()
    func injected(from base: ViewBase) throws -> Self
    var customFields : [DatabaseQuery.Field] {get}
    
}

public protocol Initializable {
    init()
}

// MARK: ViewBinder

public final class ViewBinder<ViewBase : FluentKit.Model, Prototype : Initializable> : DbView {
    
    var visitors = [(ViewBase, inout Prototype) -> Void]()
    internal(set) public var customFields = [DatabaseQuery.Field]()
    private(set) public var prototype : Prototype
    
    init(prototype : Prototype) {
        self.prototype = prototype
    }
    
    // conformance
    
    public convenience init() {
        self.init(prototype: .init())
    }
    public func injected(from base: ViewBase) -> Self {
        for visitor in visitors {
            visitor(base, &prototype)
        }
        return self
    }
    
}

public extension QueryBuilder {
    
    func bind<NewView>(to prototype: NewView) -> QueryBuilder<NewView>
    where
    NewView : DbView,
    NewView.ViewBase == View.ViewBase {
        
        var query = self.query
        query.fields = []
        
        return .init(query: query,
                     database: database,
                     models: models,
                     prototype: prototype,
                     eagerLoaders: eagerLoaders,
                     includeDeleted: includeDeleted,
                     shouldForceDelete: shouldForceDelete)
        
    }
    
    func project<NewView>(onto prototype: NewView)
    -> QueryBuilder<ViewBinder<View.ViewBase, NewView>> {
        
        bind(to: .init(prototype: prototype))
        
    }
    
    func bind<Base, Wrapped : Initializable, Property : QueryableProperty>(
        _ prop: KeyPath<Model, Property>,
        to writable: WritableKeyPath<Wrapped, Property>) -> Self
    where
    View == ViewBinder<Base, Wrapped> {
        prototype.customFields.append(.path(Base.path(for: prop), schema: Base.schema))
        prototype.visitors.append {model, proto in
            proto[keyPath: writable] = model[keyPath: prop]
        }
        return self
    }
    
}

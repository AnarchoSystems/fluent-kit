extension QueryBuilder {
    @discardableResult
    public func group(
        _ relation: DatabaseQuery.Filter.Relation = .and,
        _ closure: (Self) throws -> ()
    ) rethrows -> Self {
        let group = Self(database: self.database)
        try closure(group)
        if !group.query.filters.isEmpty {
            self.query.filters.append(.group(group.query.filters, relation))
        }
        return self
    }
}

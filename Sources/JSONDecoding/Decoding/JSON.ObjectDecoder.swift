extension JSON
{
    /// A thin wrapper around a native Swift dictionary providing an efficient decoding
    /// interface for a JSON object.
    @frozen public
    struct ObjectDecoder<CodingKey> where CodingKey:RawRepresentable<String> & Hashable
    {
        public
        var index:[CodingKey: JSON]
        
        @inlinable public
        init(_ index:[CodingKey: JSON] = [:])
        {
            self.index = index
        }
    }
}
extension JSON.ObjectDecoder:JSONDecodable
{
    @inlinable public
    init(json:JSON) throws
    {
        try self.init(indexing: try .init(json: json))
    }
}
extension JSON.ObjectDecoder where CodingKey:RawRepresentable<String>
{
    @inlinable public
    init(indexing object:JSON.Object) throws
    {
        self.init(.init(minimumCapacity: object.count))
        for field:JSON.ExplicitField<String> in object
        {
            guard let key:CodingKey = .init(rawValue: field.key)
            else
            {
                continue
            }
            if case _? = self.index.updateValue(field.value, forKey: key)
            {
                throw JSON.ObjectKeyError<CodingKey>.duplicate(key)
            }
        }
    }
}
extension JSON.ObjectDecoder
{
    @inlinable public __consuming
    func single() throws -> JSON.ExplicitField<CodingKey>
    {
        guard let (key, value):(CodingKey, JSON) = self.index.first
        else
        {
            throw JSON.SingleKeyError<CodingKey>.none
        }
        if self.index.count == 1
        {
            return .init(key: key, value: value)
        }
        else
        {
            throw JSON.SingleKeyError<CodingKey>.multiple
        }
    }
    
    @inlinable public
    subscript(key:CodingKey) -> JSON.ExplicitField<CodingKey>?
    {
        self.index[key].map { .init(key: key, value: $0) }
    }
    @inlinable public
    subscript(key:CodingKey) -> JSON.ImplicitField<CodingKey>
    {
        .init(key: key, value: self.index[key])
    }
}

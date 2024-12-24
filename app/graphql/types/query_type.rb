module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.
    field :orders, [Types::OrderType], null: false
    def orders
      Order.all
    end
  end
end

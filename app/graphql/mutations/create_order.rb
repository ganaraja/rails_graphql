class Mutations::CreateOrder < Mutations::BaseMutation

    argument :full_name, String, required: true
    argument :address, String, required: true
    argument :status, String, required: true
    argument :item_name, String, required: true
    argument :total, Integer, required: true

    def resolve( full_name:, address:, status:, item_name:, total: )
    	order = Order.new(full_name: full_name, address: address, status: status, item_name: item_name, total: total)
    
    	if order.save
    		{order: order, errors: []}
    	else
    		{order: nil, errors: order.errors.full_messages}
    	end
    end

end
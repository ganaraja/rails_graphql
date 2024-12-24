require 'rails_helper'

describe 'Orders', type: :request do
  describe 'Query "orders"' do
    context 'when there are no orders in the system' do
      it 'returns empty list' do

        post '/graphql', params: { query: orders_query }
        
        expected = {
          data: {
            orders: []
          }
        }.deep_stringify_keys
        
        expect(JSON.parse(response.body)).to eq(expected)
      end
    end

    context 'when there are orders in the system' do
      let(:orders) do
        [
          {
            full_name: 'Mary Smith',
            address: 'Howard Street Oswego NY 13126',
            status: 'UNPAID',
            item_name: 'Cup',
            total: 2100
          },
          {
            full_name: 'Bryanna Davies',
            address: 'Howard Street Oswego NY 13127',
            status: 'PAID',
            item_name: 'Pen',
            total: 100
          }
        ]
      end

      before do
        orders.each do |order_params|
          post '/graphql', params: { query: create_order_mutation(**order_params) }
          fail('Cannot add orders using mutation') if JSON.parse(response.body)['errors'].present?
        end
      end

      it 'returns orders ordered by ID' do
        post '/graphql', params: { query: orders_query }

        expected_orders = orders.each.with_index(1) do |order_params, index|
          order_params[:id] = index.to_s
        end

        expected_orders = expected_orders.map { |order| camelize_keys(order) }
        expected = { data: { orders: expected_orders } }.deep_stringify_keys
        expect(JSON.parse(response.body)).to eq(expected)
      end

      context 'when argument "status" is passed' do
        it 'returns orders with specified status only' do
          post '/graphql', params: { query: orders_query(status: 'PAID') }
          expected_orders = [
            {
              id: '2',
              full_name: 'Bryanna Davies',
              address: 'Howard Street Oswego NY 13127',
              status: 'PAID',
              item_name: 'Pen',
              total: 100
            }
          ]

          expected_orders = expected_orders.map {|params| camelize_keys(params)}
          expected = { data: { orders: expected_orders } }.deep_stringify_keys
          expect(JSON.parse(response.body)).to eq(expected)
        end
      end
    end
  end

  describe 'Mutation "createOrders"' do
    let(:full_name) { 'Nick Wilson' }
    let(:address) { '2454  Brighton Circle Road, Minnesota' }
    let(:status) { 'PAID' }
    let(:item_name) { 'Suitcase' }
    let(:total) { 200 }

    let(:params) do
      {
        full_name: full_name,
        address: address,
        status: status,
        item_name: item_name,
        total: total
      }
    end

    let(:parsed_response) { JSON.parse(response.body) }

    before do
      post '/graphql', params: { query: create_order_mutation(**params) }
    end

    context 'when all parameters are valid' do
      it 'returns order with assigned ID' do
        expect(parsed_response['data']['createOrder']).to be_present

        expected = {**params, id: '1'}.stringify_keys
        expected = camelize_keys(expected)
        expect(parsed_response['data']['createOrder']['order']).to eq(expected)
      end

      it 'saves order to database' do
        post '/graphql', params: { query: orders_query }

        expected_orders = [camelize_keys({**params, id: '1'})]

        expected = { data: { orders: expected_orders } }.deep_stringify_keys
        expect(JSON.parse(response.body)).to eq(expected)
      end
    end

    context 'when "full_name" is not provided' do
      let(:full_name) { nil }

      it 'returns "Full name can\'t be blank" error' do
        expect(parsed_response['data']['createOrder']).to eq(nil)
        expect(parsed_response['errors']).to be_present
        expect(parsed_response['errors'].size).to eq(1)
        expect(parsed_response['errors'][0]).to include(
          {'message' => 'Full name can\'t be blank'}
        )
      end
    end

    context 'when "address" if not provided' do
      let(:address) { nil }

      it 'returns "Address can\'t be blank" error' do
        expect(parsed_response['data']['createOrder']).to eq(nil)
        expect(parsed_response['errors']).to be_present
        expect(parsed_response['errors'].size).to eq(1)
        expect(parsed_response['errors'][0]).to include(
          {'message' => 'Address can\'t be blank'}
        )
      end
    end

    context 'when "status" is not provided' do
      let(:status) { nil }

      it 'returns "Status can\'t be blank" error' do
        expect(parsed_response['data']['createOrder']).to eq(nil)
        expect(parsed_response['errors']).to be_present
        expect(parsed_response['errors'].size).to eq(1)
        expect(parsed_response['errors'][0]).to include(
          {'message' => 'Status can\'t be blank'}
        )
      end
    end

    context 'when "item_name" is not provided' do
      let(:item_name) { nil }

      it 'returns "Item name can\'t be blank" error' do
        expect(parsed_response['data']['createOrder']).to eq(nil)
        expect(parsed_response['errors']).to be_present
        expect(parsed_response['errors'].size).to eq(1)
        expect(parsed_response['errors'][0]).to include(
          {'message' => 'Item name can\'t be blank'}
        )
      end
    end

    context 'when "total" is not provided' do
      let(:total) { nil }

      it 'returns "Total can\'t be blank" error' do
        expect(parsed_response['data']['createOrder']).to eq(nil)
        expect(parsed_response['errors']).to be_present
        expect(parsed_response['errors'].size).to eq(1)
        expect(parsed_response['errors'][0]).to include(
          {'message' => 'Total can\'t be blank'}
        )
      end
    end

    context 'when no parameters are provided' do
      let(:full_name) { nil }
      let(:address) { nil }
      let(:status) { nil }
      let(:item_name) { nil }
      let(:total) { nil }

      it 'returns errors concatenated with dot' do
        expect(parsed_response['data']['createOrder']).to eq(nil)
        expect(parsed_response['errors']).to be_present
        expect(parsed_response['errors'].size).to eq(5)

        error_messages = parsed_response['errors'].map do |error|
          error['message']
        end

        expect(error_messages).to match_array([
          'Full name can\'t be blank',
          'Address can\'t be blank',
          'Status can\'t be blank',
          'Item name can\'t be blank',
          'Total can\'t be blank'
        ])
      end
    end
  end
end

def orders_query(status: nil)
  <<~GQL
  query {
    orders#{status ? "(status: #{sanitize_arg(status)})" : ''} {
      id
      fullName
      address
      status
      itemName
      total
    }
  }
  GQL
end

def create_order_mutation(full_name:, address:, status:, item_name:, total:)
  <<~GQL
  mutation {
    createOrder(
      input: {
        fullName: #{sanitize_arg(full_name)},
        address: #{sanitize_arg(address)},
        status: #{sanitize_arg(status)},
        itemName: #{sanitize_arg(item_name)},
        total: #{sanitize_arg(total)}
      }
    ) {
      order {
        id
        fullName
        address
        status
        itemName
        total
      }
    }
  }
  GQL
end

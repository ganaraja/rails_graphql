# Ruby on Rails: Orders Management with GraphQL

## Project Specifications

**Read-Only Files**
- spec/*

**Environment**  

- Ruby version: 3.2.2
- Rails version: 7.0.0
- Default Port: 8000

**Commands**
- run: 
```bash
bin/bundle exec rails server --binding 0.0.0.0 --port 8000
```
- install: 
```bash
bin/bundle install
```
- test: 
```bash
RAILS_ENV=test bin/rails db:migrate && RAILS_ENV=test bin/bundle exec rspec
```
    
## Question description

In this challenge, you are part of a team that is building an eCommerce Platform. One requirement is for a GraphQL API service to persist and retrieve orders information using the Rails framework. You will need to add functionality to create orders, fetch them, and perform some queries. The team has come up with a set of requirements including API format, response codes, and data validations.

The definitions and detailed requirements list follow. You will be graded on whether your application performs data retrieval and manipulation based on given use cases exactly as described in the requirements.

Each order has the following structure:

- `id`: The unique ID of the order
- `fullName`: The full name of the customer
- `address`: The order delivery address
- `status`: The status of the order (either `PAID` or `UNPAID`).
- `itemName`: The name of an item bought
- `total`: The total price of the order in cents

### Example of an order JSON object:
```
{
  "id": 1,
  "fullName": "Bryanna Davies",
  "address": "Howard Street Oswego NY 13127",
  "status": "PAID",
  "itemName": "Rainbow - On Stage (vinyl)",
  "total": 3000
}
```

## Requirements:

You are provided with the implementation of the Order model. The REST service must expose the `/graphql` endpoint, which allows for managing the collection of orders in the following way:

- Query `orders`:
  - returns the collection of all orders, ordered by id in increasing order
  - accepts the optional argument `status`. When `status` is provided, returns orders with a specified status only. 

- Mutation `createOrder`:
  - accepts arguments:
    - fullName (string)
    - address (string)
    - status (string)
    - itemName (string)
    - total (integer)
  - performs following validations:
    - fullName should be present
    - address should be present
    - status should be present
    - itemName should be present
    - total should be present
  - if any validation from the above fails, returns an error message in the following format:
    ```
    {
      "data": {
        "createOrder": null
      },
      "errors": [
        {
          "message": "Full name can't be blank"
        }
      ]
    }
    ```
  
  If multiple fields are missing, then multiple errors should be returned:

  ```
    {
      "data": {
        "createOrder": null
      },
      "errors": [
        {
          "message": "Full name can't be blank"
        },
        {
          "message": "Address can't be blank"
        },
        {
          "message": "Status can't be blank"
        },
        {
          "message": "Item name can't be blank"
        },
        {
          "message": "Total can't be blank"
        }
      ]
    }
  ```

  - if all validations succeed, adds order to the database, assigns unique id, and returns order information in the request response


## Example requests and responses:

- Query `orders`:

  Query:
  ```
  query {
    orders {
      id
      fullName
      address
      status
      itemName
      total
    }
  }
  ```

  Response:
  ```
  {
    "data": {
      "orders": [
        {
          "id": "1",
          "fullName": "Mary Smith",
          "address": "Howard Street Oswego NY 13126",
          "status": "UNPAID",
          "itemName": "Cup",
          "total": 2100
        },
        {
          "id": "2",
          "fullName": "Bryanna Davies",
          "address": "Howard Street Oswego NY 13127",
          "status": "PAID",
          "itemName": "Pen",
          "total": 100
        }
      ]
    }
  }
  ```

  Query:

  ```
  query {
    orders(status: "PAID") {
      id
      fullName
      address
      status
      itemName
      total
    }
  }
  ```

  Response:
  ```
  {
    "data": {
      "orders": [
        {
          "id": "2",
          "fullName": "Bryanna Davies",
          "address": "Howard Street Oswego NY 13127",
          "status": "PAID",
          "itemName": "Pen",
          "total": 100
        }
      ]
    }
  }
  ```

- Mutation `createOrder`

  Query:
  ```
  mutation {
    createOrder(
      input: {
        fullName: "Nick Wilson",
        address: "2454  Brighton Circle Road, Minnesota",
        status: "PAID",
        itemName: "Suitcase",
        total: 200
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
  ```

  Response:
  ```
  {
    "data": {
      "createOrder": {
        "order": {
          "id": "1",
          "fullName": "Nick Wilson",
          "address": "2454  Brighton Circle Road, Minnesota",
          "status": "PAID",
          "itemName": "Suitcase",
          "total": 200
        }
      }
    }
  }
  ```
  

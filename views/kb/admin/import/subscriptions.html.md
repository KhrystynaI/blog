# Importing Subscriptions (Orders)

## File structure

Orders are imported from a .csv file.

The following columns are taken into account:

| Column Title          | Description               | Example               |
|-----------------------|---------------------------|-----------------------|
| Doc Set ID            | Document Set ID           | 266                   |
| Version               | Document Set Version      | 2                     |
| Title                 | Document Set Title        | The Gartman Letter    |
| Vendor                | Vendor Name               | Advertising Age       |
| Order ID              | Subscription Order ID     | UK-327900             |
| Delivery end          | Subscription expiry date  | 31/08/2017            |
| Employee ID No        | Subscriber ID             | G49921257             |
| Subscriber First Name | Subscriber First Name     | Scotty                |
| Subscriber Last Name  | Subscriber Last Name      | Gattner               |
| Deliver Address       | Subscriber Full Address   | Scotty Gattner, Big Capital, NNN Avenue, Floor NN, New York, NY 100NN, USA |

All othe columns that the .csv file can contain will be ignored.

All data is tied to the customer specified on the Import page. 
Note: the Customer column that might be present in the .csv file will be ignored.


## Import process

The import goes over .csv file and processes record by record.

Steps importing a single record as follows:

- Validate the .csv record: required columns and values should be present. If record is invalid mark it and skip to the next record.
- Find the vendor by Vendor Name. Create a new vendor if vendor is not found in database.
- Find the document set by the DocSetID, Version and Customer specified before uploading the file. Create a new DocSet if not found.
  - Update the document set title if changed.
- Find the order item by the OrderID and Customer.
  - If Order Item is found: 
    - Update or replace the subscriber:
      - Compare existing Subscriber name with the name from .csv record:
        - If the name is different (differs in more than 3 characters) - treat it as a different user and replace the subscriber.
        - If the name is similar or equal (differs in 3 or less characters) -
          treat it as a typo and update the user details (name and address).
    - Update order item expiry date if changed.
  - If Order Item is not found:
    - Find the subscriber by the Customer, First and Last name (match similar user in the document set)
      - Update subscriber details: name, address.
    - Create a new subscriber if not found neither match similar.
    - Create a new order item with the subscriber found or created.
    
The Import report is saved and can be verified later by navigating Admin => System => [Import Reports](/admin/import_reports) => view.





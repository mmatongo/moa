# Moa

This is a simple Sinatra application that provides a RESTful API for a user-associated key-value store. Users can sign up, store complex JSON objects associated with a key, and retrieve them using a unique ID.

## Features

- User signup and token-based authentication.
- Store, retrieve, update, and delete complex JSON objects.
- Each user's data is isolated from others.
- Data persistence using PStore.

## Setup & Installation

1. Clone the repository:

   ```bash
   git clone git@github.com:mmatongo/moa.git
   ```

   ```bash
   cd moa
   ```

2. Install the required gems:

   ```bash
    bundle install
   ```

3. Run the application:

   ```bash
   ruby moa.rb
   ```

## API Endpoints

### Signup

- **Endpoint**: `/signup`
- **Method**: `POST`
- **Data**: `json {"username": "your_username"}`
- **Response**: A unique token for authentication.

### Store a new object

- **Endpoint**: `/:username/:key`
- **Method**: `POST`
- **Headers**: `Authorization: your_token`
- **Data**: Any valid JSON object.
- **Response**: A unique ID for the stored object.

### Get an object by key and ID

- **Endpoint**: `/:username/:key/:id`
- **Method**: `GET`
- **Headers**: `Authorization: your_token`
- **Response**: The stored JSON object.

### Update an object by key and ID

- **Endpoint**: `/:username/:key/:id`
- **Method**: `PUT`
- **Headers**: `Authorization: your_token`
- **Data**: Updated JSON object.

### Delete an object by key and ID

- **Endpoint**: `/:username/:key/:id`
- **Method**: `DELETE`
- **Headers**: `Authorization: your_token`

## Usage

### Using `curl`:

1. **Signup**:
   ```bash
   curl -X POST -H "Content-Type: application/json" -d '{"username": "mmatongo"}' http://127.0.0.1:4567/signup
   ```

2. **Store a new object** (e.g., under the key "profile"):
   ```bash
   curl -X POST -H "Content-Type: application/json" -H "Authorization: ae7814054b59235ce80ee44e926f77c175291186c5f5d7472e" -d '{"name": "John", "age": 30, "city": "New York"}' http://127.0.0.1:4567/mmatongo/profile
   ```

   This will return a unique ID for the object.

3. **Get the object by key and ID** (e.g., "profile" and the returned ID):
   ```bash
   curl -X GET -H "Authorization: ae7814054b59235ce80ee44e926f77c175291186c5f5d7472e" http://127.0.0.1:4567/mmatongo/profile/unique_id
   ```

4. **Update the object by key and ID**:
   ```bash
   curl -X PUT -H "Content-Type: application/json" -H "Authorization: ae7814054b59235ce80ee44e926f77c175291186c5f5d7472e" -d '{"name": "Jane", "age": 25, "city": "Los Angeles"}' http://127.0.0.1:4567/mmatongo/profile/unique_id
   ```

5. **Delete the object by key and ID**:
   ```bash
   curl -X DELETE -H "Authorization: ae7814054b59235ce80ee44e926f77c175291186c5f5d7472e" http://127.0.0.1:4567/mmatongo/profile/unique_id
   ```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License.

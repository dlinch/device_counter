# Device Counter

This project spins up a small API to store and return device reading timestamps and counts. It provides three endpoints:

## API Summary

```
GET /device_readings/<ID>
POST /device_readings
GET /device_readings
```

The first endpoint fetches a devices current count and it's latest recorded timestamp using a device ID.
The second endpoint receives readings for a device id and stores them for later retrieval.
The third endpoint is only available outside of production environments and is intended for debugging, it returns all values inside the store.

The API is Non-Atomic, meaning it will return 200 if any of the operations succeed. So if two readings are sent in a POST and one fails, the API will operate on the successful payload and return a 200, but with an errors body denoting the second payload that failed.

The response time with limited local testing is around the 15ms mark. The storage will grow linearly with each unique device and each unique reading.

## Project Summary

This project is run on Rails 7.1.3 using Ruby 3.3.4.

The project uses the ActiveSupport::Cache::MemoryStore to store a devices total count, it's latest timestamp, and each unique timestamp + device_id combination to prevent duplicate operations. The memory store is thread safe, and utilizes memory as per the requirements.

The memory store is wrapped with a Creator service class, which performs the calculations to determine if a device reading is valid, if it is a duplicate, and to update the cache values when appropriate. An abstract ActiveRecord model is used for the basic validation of a device reading, to do some light data massaging, and to build the relevant cache keys.

An orchestrator class takes the multiple readings format of the payload, builds an individual reading's params with some light data type massaging. It calls on the Creator for each reading instance, and bundles up the total errors. A very light monad pattern is used to determine whether an action succeeded or not, and those monads are bundled up in the orchestrator to determine total, partial, or zero success states for the API response.

The first pass at this solution was using SQLite's in-memory database option, but that proved to be painful when actually spinning up the server, so the memory store was used instead. There is some holdover code to this effect, such as instantiating the store in an initializer, and some of the parameter translation, eg `id -> device_id`, `timestamp -> timestamp_at`, as I was trying to follow some DB column name standards.

There are requests specs testing the code at the controller level, a few model validation specs, and a lot of unit specs on the custom Ruby service classes. Custom RSpec matchers are used heavily to make the testing of cache keys and their values easier.

### Starting the Project

Ensure you have Ruby 3.3.4 availble in your shell when attempting to install dependencies and run the project. Preferred methods include rbenv, ASDF, etc.

Ensure bundler is installed locally:
`gem install bundler`

Then bundle the project dependencies.
`bundle install`

Start the server.
`bundle exec rails s`

The project should be available locally at `localhost:3000`.

Run specs.
`bundle exec rspec`

### Testing the Project

You will need your favorite API testing tool to send posts to the endpoint, likely something like Postman, Insomnia, Jmeter, or good ol' fashioned curl from the command line.

I recommend the following steps to test:

- GET to `localhost:3000/device_readings/36d5658a-6908-479e-887e-a949ec199272`
- Check the response is `{cumulative_count: null, latest_timestamp: null}`
- POST to `local_host:3000/device_readings/` with the payload available in `spec/support/fixtures/post_1.json`.
- Check the response is 200 with no body
- Repeat previous POST step
- Check the response is 422, with an error body containing two error entries
- GET to `localhost:3000/device_readings/36d5658a-6908-479e-887e-a949ec199272`
- Check the response is `{cumulative_count: 17, latest_timestamp: "2021-09-29T16:09:15+01:00"}`
- POST to `local_host:3000/device_readings/` with the payload available in `spec/support/fixtures/post_2.json`
- Check the response is 200 ok, but with an error body containing 1 duplicate error entry
- GET to `localhost:3000/device_readings/36d5658a-6908-479e-887e-a949ec199272`
- Check the response is `{cumulative_count: 21, latest_timestamp: "2021-09-29T16:10:15+01:00"}`. This means the count and timestamp were updated.

### Follow On Improvments/Work

- Add a custom service class to handle the reading endpoint, removing some logic from the controller.
- Backtrack attribute renaming of ID -> Service ID and Timestamp -> Timestamp At.
- Validation that ID is a UUID.
- Remove more of the SQLite DB Testing work, and the associated model DSL for querying against a SQL store.
- Remove the device storage singleton.
- Use something like [Dry Schema/Types](https://dry-rb.org/gems/dry-types/1.2/) to better handle massaging of incoming data into their appropriate types, as well as building their validation error messages. AR felt clunky, but I had already started that path when trying to use SQLite.
- Utilize a more fleshed out Monad pattern to handle success/failure pass throughs.
- More robust testing against large cache values to monitor performance.
- More robust orchestrator tests
- Adding some project niceties, Standard RB, git hooks (where logical)
- Adding some more robust factory bot traits/states so test setup doesn't require a user to hit the store twice to test change events

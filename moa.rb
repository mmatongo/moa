require 'sinatra'
require 'json'
require 'thread'
require 'securerandom'
require 'pstore'

set :server, 'thin'

Dir.mkdir('databases') unless File.exist?('databases')
$store_db = PStore.new('databases/store.db')
$users_db = PStore.new('databases/users.db')
$mutex = Mutex.new

helpers do
  def parsed_body
    JSON.parse(request.body.read)
  end

  def halt(code, body = nil)
    response.status = code
    response.body = body if body
    throw :halt
  end

  def json_response(data)
    content_type :json
    data.to_json
  end

  def json_success(message)
    json_response(success: message)
  end

  def json_error(code, message)
    halt code, json_response(error: message)
  end

  def current_user
    token = request.env['HTTP_AUTHORIZATION']
    $users_db.transaction(true) { $users_db['data']&.key(token) }
  end
end

def authenticate!
  halt 403 unless current_user
end

post '/signup' do
  data = parsed_body
  username = data['username']
  token = SecureRandom.hex(25)

  $mutex.synchronize do
    $users_db.transaction do
      users = $users_db['data'] || {}
      users[username] = token
      $users_db['data'] = users
    end
  end

  json_response token: token
end

get '/:username' do
  authenticate!

  username = params['username']
  halt 403 unless username == current_user

  $store_db.transaction(true) { $store_db[username]['profile'] }.to_json
end

get '/:username/:key/:id' do
  authenticate!

  username = params['username']
  halt 403 unless username == current_user

  key = params['key']
  id = params['id']
  value = $store_db.transaction(true) { $store_db[username]&.[](key)&.[](id) }

  if value
    json_response id => value
  else
    json_error 404, "Object not found"
  end
end

post '/:username/:key' do
  authenticate!

  username = params['username']
  halt 403 unless username == current_user

  key = params['key']
  data = parsed_body
  id = SecureRandom.hex(10)

  $mutex.synchronize do
    $store_db.transaction do
      store = $store_db[username] || {}
      store[key] = store[key] || {}
      store[key][id] = data
      $store_db[username] = store
    end
  end

  json_response id: id
end

put '/:username/:key/:id' do
  authenticate!

  username = params['username']
  halt 403 unless username == current_user

  key = params['key']
  id = params['id']
  data = parsed_body

  $mutex.synchronize do
    $store_db.transaction do
      store = $store_db[username] || {}
      store[key] = store[key] || {}
      store[key][id] = data
      $store_db[username] = store
    end
  end

  json_success "Value updated successfully"
end

delete '/:username/:key/:id' do
  authenticate!

  username = params['username']
  halt 403 unless username == current_user

  key = params['key']
  id = params['id']

  $mutex.synchronize do
    $store_db.transaction do
      store = $store_db[username] || {}
      store[key]&.delete(id)
      $store_db[username] = store
    end
  end

  json_success "Object deleted"
end

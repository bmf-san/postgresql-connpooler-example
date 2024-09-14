require 'pg'
require 'webrick'
require 'json'

# pgcat
CONN = {
  host: 'pgcat',
  port: 6432,
  dbname: 'db',
  user: 'user',
  password: 'password'
}

# postgres
# CONN = {
#   host: 'postgres',
#   port: 5432,
#   dbname: 'example',
#   user: 'user',
#   password: 'password'
# }

class MyApi < WEBrick::HTTPServlet::AbstractServlet
  def initialize(server)
    super(server)
  end

  def get_via_pgcat(limit = 100)
    conn = nil
    begin
      conn = PG.connect(CONN)
      result = conn.exec_params("SELECT * FROM products LIMIT $1", [limit])

      # Explicitly handle the case where the result might be empty due to connection issues
      if result.ntuples == 0
        { error: 'No data found' }
      else
        { data: result.values }
      end
    rescue PG::ConnectionBad => e
      puts "Connection error with pgcat: #{e.message}"
      { error: 'Database connection error' }
    rescue PG::UnableToSend => e
      puts "Unable to send data to pgcat: #{e.message}"
      { error: 'Unable to send data' }
    rescue PG::ResultError => e
      puts "Result error with pgcat: #{e.message}"
      { error: 'Query result error' }
    rescue PG::Error => e
      puts "General pgcat error: #{e.message}"
      { error: 'Database error' }
    ensure
      conn&.close
    end
  end

  def insert_via_pgcat(name, category_id, price, stock)
    conn = nil
    begin
      conn = PG.connect(CONN)
      conn.exec_params("INSERT INTO products (name, category_id, price, stock) VALUES ($1, $2, $3, $4)", [name, category_id, price, stock])
      { status: 'inserted', name: name, category_id: category_id, price: price, stock: stock }
    rescue PG::ConnectionBad => e
      puts "Connection error with pgcat: #{e.message}"
      { error: 'Database connection error' }
    rescue PG::UnableToSend => e
      puts "Unable to send data to pgcat: #{e.message}"
      { error: 'Unable to send data' }
    rescue PG::ResultError => e
      puts "Result error with pgcat: #{e.message}"
      { error: 'Query result error' }
    rescue PG::Error => e
      puts "General pgcat error: #{e.message}"
      { error: 'Database error' }
    ensure
      conn&.close
    end
  end

  def do_GET(request, response)
    if request.path == '/products'
      limit = request.query['limit'] ? request.query['limit'].to_i : 100
      result = get_via_pgcat(limit)

      if result[:error]
        response.status = 500
        response['Content-Type'] = 'application/json'
        response.body = { error: result[:error] }.to_json
      else
        # Explicitly handle empty results with a 500 status
        if result[:data].empty?
          response.status = 500
          response['Content-Type'] = 'application/json'
          response.body = { error: 'Database returned empty result' }.to_json
        else
          response.status = 200
          response['Content-Type'] = 'application/json'
          response.body = result[:data].to_json
        end
      end
    else
      response.status = 404
      response['Content-Type'] = 'application/json'
      response.body = { error: 'Not found' }.to_json
    end
  end

  def do_POST(request, response)
    if request.path == '/products/create'
      data = JSON.parse(request.body)
      result = insert_via_pgcat(data['name'], data['category_id'], data['price'], data['stock'])

      if result[:error]
        response.status = 500
        response['Content-Type'] = 'application/json'
        response.body = { error: result[:error] }.to_json
      else
        response.status = 201
        response['Content-Type'] = 'application/json'
        response.body = result.to_json
      end
    else
      response.status = 404
      response['Content-Type'] = 'application/json'
      response.body = { error: 'Not found' }.to_json
    end
  end
end

server = WEBrick::HTTPServer.new(Port: 8080)
server.mount '/', MyApi
trap('INT') { server.shutdown }
server.start

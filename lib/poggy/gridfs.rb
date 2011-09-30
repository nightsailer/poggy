# encoding: UTF-8
require "mongo"
module Poggy
  class Gridfs
    def initialize(app,options)
      @app = app
      @gridfs = Mongo::Grid.new(options[:db])
    end

    def call(env)
      with_rescues  do
        request = Rack::Request.new(env)
        id = %r!^/(.+)\..+!.match(request.path_info)[1]
        logger.debug "path_info:#{request.path_info} id:#{id}"
        file = @gridfs.get(BSON::ObjectId.from_string(id))
        response_for(file, request)
      end
    end

    def with_rescues
      rescue_connection_failure { yield }
    rescue Mongo::GridFileNotFound, BSON::InvalidObjectId => e
      [ 404, {'Content-Type' => 'text/plain'}, ["File not found. #{e}"] ]
    rescue Mongo::GridError => e
      [ 500, {'Content-Type' => 'text/plain'}, ["An error occured. #{e}"] ]
    end

    def rescue_connection_failure(max_retries=5)
      retries = 0
      begin
        yield
      rescue Mongo::ConnectionFailure => e
        retries += 1
        raise e if retries > max_retries
        sleep(0.5)
        retry
      end
    end

    def response_for(file, request)
      # todo, make file streaming
      [ 200, { 'Content-Type' => 'image/jpeg' }, file ]
    end
  end
  class GridfsApp < Padrino::Application
    disable :sessions
    disable :flash
    use  Gridfs,:db => Mongoid::database
  end
end

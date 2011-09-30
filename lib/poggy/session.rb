# encoding: UTF-8
require 'rack/session/abstract/id'
require 'thread'
require "mongo"
module Poggy
  class Session < Rack::Session::Abstract::ID
    attr_reader :mutex,:session_col

    def initialize(app,options={})
      super

      @mutex = Mutex.new
      @session_col = options[:session_col]
      raise 'mongodb session collection not given' if @session_col.nil?
    end

    def generate_sid; BSON::ObjectId.new.to_s end

    def get_session(env, sid)
      with_lock(env, [nil, {}]) do
        unless sid and session = @session_col.find_one(BSON::ObjectId.from_string(sid))
          sid, session = generate_sid, {}
        end
        session.delete "_id"
        [sid, session]
      end
    end

    def set_session(env, session_id, new_session, options)
      with_lock(env, false) do
        new_session[:_id] = BSON::ObjectId.from_string(session_id)
        @session_col.save(new_session)
        session_id
      end
    end

    def destroy_session(env, session_id, options)
      with_lock(env) do
        @session_col.remove({:_id => BSON::ObjectId.from_string(session_id)}) unless options[:lazy_drop]
        generate_sid unless options[:drop]
      end
    end

    def with_lock(env, default=nil)
      @mutex.lock if env['rack.multithread']
      yield
    rescue Mongo::ConnectionError,Mongo::MongoRubyError
      if $VERBOSE
        warn "#{self} failed to lookup mongodb server."
        warn $!.inspect
      end
      default
    ensure
      @mutex.unlock if @mutex.locked?
    end
  end  
end
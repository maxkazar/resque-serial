require 'resque-serial'
require 'resque/server'
require 'yaml'

module ResqueSerial
  module Server
    def self.registered(app)

      app.class_eval do

        helpers do
          def render_view(filename)
            erb File.read(File.join(File.dirname(__FILE__), 'server', 'views', "#{filename}.erb"))
          end
        end

        get '/serials' do
          @serials = Redis.current.keys 'resque:syncjobs:*'
          @serials.map! { |serial| { name: serial.split(':').last, size: Redis.current.llen(serial) } }
          render_view :serials
        end

        get '/serials/:id' do
          @serial_name = params[:id]
          serial = "resque:syncjobs:#{@serial_name}"
          @count = Redis.current.llen serial
          @jobs = Redis.current.lrange serial, 0, @count

          @jobs.map! { |job| YAML.load job }
          render_view :serial
        end

        post '/serials/:id/remove' do
          serial = "resque:syncjobs:#{params[:id]}"
          Redis.current.del serial
          redirect u(:serials)
        end
      end
    end

    Resque::Server.tabs << 'Serials'

  end
end

Resque::Server.register ResqueSerial::Server

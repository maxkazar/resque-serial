module ResqueSerial
  class AsyncJob
    class << self
      def queue
        :sync
      end

      # Add a job to queue. Queue name is a class module name
      def create(target, queue, *args)
        if queue
          Resque.enqueue_to queue, self, enqueue_payload(target, queue, *args)
        else
          Resque.enqueue self, enqueue_payload(target, queue, *args)
        end
      end

      def enqueue_payload(target, queue, *args)
        method = args.shift()
        options = {
            class: target.class.to_s,
            id: target.id.to_s,
            method: method,
            args: args,
        }
        options[:scope] = target.scope && !target.scope.is_a?(String) ? target.scope.id.to_s : target.scope
        options[:timestamp] = target.timestamp if target.respond_to? :timestamp

        options
      end

      def perform(options)
        options.symbolize_keys!
        model = options[:class].constantize.unscoped.find(options[:id])
        model.scope = options.delete(:scope)
        model.timestamp = options.delete(:timestamp)
        model.send options[:method], *options[:args]
      end
    end
  end
end
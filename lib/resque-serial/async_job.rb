module ResqueSerial
  class AsyncJob
    class << self
      def queue
        :async
      end

      # Add a job to queue. Queue name is a class module name
      def create(target, queue, *args)
        Resque.enqueue self, enqueue_payload(target, queue, *args)
      end

      def enqueue_payload(target, queue, *args)
        method = args.shift()
        options = {
            class: target.class.to_s,
            id: target.id.to_s,
            method: method,
            args: args,
        }
        options[:scope] = target.scope.id.to_s if target.scope

        options
      end

      def perform(options)
        options.symbolize_keys!
        model = options[:class].constantize.unscoped.find(options[:id])
        model.scope = options.delete(:scope)
        model.send options[:method], *options[:args]
      end
    end
  end
end
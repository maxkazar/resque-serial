module ResqueSerial
  class AsyncJob
    class << self
      def queue
        :async
      end

      # Add a job to queue. Queue name is a class module name
      def create(target, queue, *args)
        Resque.enqueue self, target, queue, *args
      end

      def perform(queue)
        options = dequeue_payload queue
        model = options[:class].constantize.unscoped.find(options[:id])
        model.scope = options.delete(:scope)
        model.send options[:method], *options[:args]
      end
    end
  end
end
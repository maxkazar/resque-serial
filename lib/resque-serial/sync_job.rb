module ResqueSerial
  class SyncJob
    extend Lockable

    attr_reader :options

    class << self
      def queue
        :sync
      end

      def lock_key(queue)
        queue
      end

      # Add a job to queue. Queue name is a class module name
      def create(target, *args)
        enqueue_payload target, *args

        Resque.enqueue(self, target.queue)
      end

      def enqueue_payload(target, method, *args)
        options = {
          class: target.class.to_s,
          id: target.id.to_s,
          method: method,
          args: args
        }
        Resque.redis.rpush "syncjobs:#{target.queue}", options.to_yaml
      end

      def dequeue_payload(queue)
        YAML.load Resque.redis.lpop "syncjobs:#{queue}"
      end

      def perform(queue)
        options = dequeue_payload queue
        model = options[:class].constantize.unscoped.find(options[:id])
        model.send options[:method], *options[:args]
      end
    end
  end
end
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
      def create(target, queue, *args)
        enqueue_payload target, queue, *args

        Resque.enqueue(self, queue)
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

        Resque.redis.rpush "syncjobs:#{queue}", options.to_yaml
      end

      def dequeue_payload(queue)
        YAML.load Resque.redis.lpop "syncjobs:#{queue}"
      end

      def perform(queue)
        options = dequeue_payload queue

        model = options[:class].constantize.unscoped.where(id: options[:id]).first
        return unless model

        model.scope = options.delete(:scope)
        model.send options[:method], *options[:args]
      end

      def size_of(queue)
        Resque.redis.llen("syncjobs:#{queue}")
      end
    end
  end
end
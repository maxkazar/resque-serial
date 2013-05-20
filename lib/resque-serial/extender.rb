module ResqueSerial
  module Extender
    class SyncProxy
      def initialize(target, queue, async)
        @queue = queue
        @target = target
        @async = async
      end

      def method_missing(*args)
        if @async
          AsyncJob.create @target, @queue, *args
        else
          SyncJob.create @target, @queue, *args
        end
      end
    end

    def delay(options = {})
      SyncProxy.new self, options[:queue] || self.queue, options[:async]
    end

    def delay_size(queue = nil)
      SyncJob.size_of(queue || self.queue)
    end

    module ClassMethods
      def priorities
        @priorities ||= {}
      end

      def priority(name, *args)
        args.each { |arg| self.priorities[arg] = name }
      end
    end
  end
end

Object.send(:include, ResqueSerial::Extender)
Module.send(:include, ResqueSerial::Extender::ClassMethods)
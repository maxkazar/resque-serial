module ResqueSerial
  module Extender
    class SyncProxy
      def initialize(target, queue)
        @queue = queue
        @target = target
      end

      def method_missing(*args)
        SyncJob.create @target, *args
      end
    end

    def delay(queue = nil)
      SyncProxy.new self, queue || self.queue
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
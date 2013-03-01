module ResqueSerial
  module Extender
    class SyncProxy
      def initialize(target)
        @target = target
      end

      def method_missing(*args)
        SyncJob.create @target, *args
      end
    end

    def delay
      SyncProxy.new self
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
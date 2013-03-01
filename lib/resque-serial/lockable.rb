module ResqueSerial
  module Lockable

    def lock_timeout
      3600
    end

    def lock_key(*args)
      raise NotImplementedError
    end

    def get_lock(*args)
      "lock:"+lock_key(*args).to_s
    end

    def requeue_perform_delay
      1.0
    end

    def before_perform_lock(*args)
      if lock_key *args
        if Resque.redis.setnx get_lock(*args), true
          Resque.redis.expire get_lock(*args), lock_timeout
        else
          sleep requeue_perform_delay

          Resque.enqueue self, *args

          raise Resque::Job::DontPerform
        end
      end
    end

    def clear_lock(*args)
      Resque.redis.del(get_lock(*args))
    end

    def around_perform_lock(*args)
      yield
    ensure
      clear_lock(*args)
    end

    def on_failure_lock(exception, *args)
      clear_lock(*args)
    end

  end
end

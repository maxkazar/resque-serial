module ResqueSerial
  module Lockable

    # Override in your job to control the worker lock experiation time. This
    # is the time in seconds that the lock should be considered valid. The
    # default is one hour (3600 seconds).
    def worker_lock_timeout(*)
      3600
    end

    # Override in your job to control the workers lock key.
    def lock_workers(*args)
      "#{name}-#{args.to_s}"
    end

    def get_lock_workers(*args)
      "workerslock:"+lock_workers(*args).to_s
    end

    # Override in your job to change the perform requeue delay
    def requeue_perform_delay
      1.0
    end

    # Called with the job args before perform.
    # If it raises Resque::Job::DontPerform, the job is aborted.
    def before_perform_workers_lock(*args)
      if lock_workers(*args)
        if Resque.redis.setnx(get_lock_workers(*args), true)
          Resque.redis.expire(get_lock_workers(*args), worker_lock_timeout(*args))
        else
          sleep(requeue_perform_delay)
          Resque.enqueue(self, *args)
          raise Resque::Job::DontPerform
        end
      end
    end

    def clear_workers_lock(*args)
      Resque.redis.del(get_lock_workers(*args))
    end

    def around_perform_workers_lock(*args)
      yield
    ensure
      # Clear the lock. (even with errors)
      clear_workers_lock(*args)
    end

    def on_failure_workers_lock(exception, *args)
      # Clear the lock on DirtyExit
      clear_workers_lock(*args)
    end

  end
end

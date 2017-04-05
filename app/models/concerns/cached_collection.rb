module CachedCollection
  extend ActiveSupport::Concern
  REFRESH_RATE = 120

  module ClassMethods
    def cached_collection(scope, name)
      cached_collection = get_var("@@c#{name}")
      last_refresh = get_var("@@r#{name}")
      if should_fetch?(cached_collection, last_refresh)
        coll = scope.all
        class_variable_set("@@c#{name}", coll)
        class_variable_set("@@r#{name}", Time.now)
        coll
      else
        cached_collection
      end
    end

    def get_var(name)
      class_variable_defined?(name) ? class_variable_get(name) : nil
    end

    def secs_elapsed(last_refresh)
      Time.now - (last_refresh.nil?  ? 0 : last_refresh)
    end

    def should_refresh?(last_refresh)
      secs_elapsed(last_refresh) > REFRESH_RATE
    end

    def should_fetch?(data, last_refresh)
      data.nil? or should_refresh?(last_refresh)
    end
  end
end

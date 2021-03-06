module Api::Controllers::Search
  module CacheHelper
    def generate_cache_key(params)
      [params[:checkin], params[:checkout], params[:destination], params[:guest]].join('/')
    end

    def fetch_from_cache(cache_key, cache_field)
      @redis.hget(cache_key, cache_field)
    end

    def cache_result(cache_key, cache_field, result)
      @redis.hset(cache_key, cache_field, result)
      @redis.expire(cache_key, 60 * 5)
    end
  end
end

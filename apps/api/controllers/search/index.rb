require 'open-uri'
require 'oj'

module Api::Controllers::Search
  class Index
    include Api::Action
    before do
      @cache_field = 'results'.freeze
      @redis       = Redis.new(:host => 'localhost', :port => '6379')
    end

    SUPPLIERS = {
      'supplier1' => 'https://api.myjson.com/bins/2tlb8',
      'supplier2' => 'https://api.myjson.com/bins/42lok',
      'supplier3' => 'https://api.myjson.com/bins/15ktg'
    }

    params do
      required(:checkin).filled
      required(:checkout).filled
      required(:destination).filled
      required(:guest).filled
      optional(:suppliers).filled
    end

    def call(params)
      if params.valid?
        cache_key = generate_cache_key(params)
        results   = fetch_from_cache(cache_key)

        if results.nil?
          if params[:suppliers].nil?
            results = fetch_from_suppliers
          else
            select_supp = params[:suppliers].split(',')
            results = fetch_from_suppliers(select_supp)
          end

          results = Oj.dump(results)
          cache_result(cache_key, results)
        end

        status 200, results
      else
        status 402, 'Bad Request'
      end
    end

    private

    def generate_cache_key(params)
      params.to_h.values.join('/')
    end

    def fetch_from_suppliers(select_supp = nil)
      results   = [ ]
      suppliers = [ ]

      if select_supp.nil?
        SUPPLIERS.each do |k, v|
          temp = Oj.load(open(v).read) rescue { }
          temp.each do |key, _|
            suppliers << { 'id' => key, 'price' =>  _, 'supplier' => k }
          end
        end
      else
        select_supp.each do |supp|
          temp = Oj.load(open(SUPPLIERS[supp]).read) rescue { }
          temp.each do |key, _|
            suppliers << { 'id' => key, 'price' => _, 'supplier' => supp }
          end
        end
      end

      suppliers.group_by { |s| s['id'] }
        .each do |supp, entries|
        results << entries.sort_by { |e| e['price'] }.first
      end

      results
    end

    def fetch_from_cache(cache_key)
      @redis.hget(cache_key, @cache_field)
    end

    def cache_result(cache_key, result)
      @redis.hset(cache_key, @cache_field, result)
      @redis.expire(cache_key, 60 * 5)
    end
  end
end

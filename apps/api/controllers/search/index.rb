require 'open-uri'
require 'oj'

module Api::Controllers::Search
  class Index
    include Api::Action
    include CacheHelper

    before do
      @redis = Redis.new(:host => ENV['REDIS_HOST'], :port => ENV['REDIS_PORT'])
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
        suppliers = params[:suppliers].split(',') rescue [ ]
        cache_key = generate_cache_key(params).freeze

        cache_field = suppliers.empty? ? 'all' : suppliers.sort.join('/')
        results = Oj.load(fetch_from_cache(cache_key, cache_field)) rescue nil

        if results.nil?
          entries = [ ]
          supp_array = suppliers.empty? ? SUPPLIERS.keys : suppliers

          supp_array.each do |supp|
            supp_result = Oj.load(fetch_from_cache(cache_key, supp)) rescue nil

            if supp_result.nil?
              supp_result = fetch_from_supplier(supp)
            end

            entries += supp_result
            cache_result(cache_key, supp, Oj.dump(supp_result))
          end

          results = merge_entries(entries)
        end

        results = Oj.dump(results.sort_by { |r| r['price'] })
        cache_result(cache_key, cache_field, results)
        status 200, results
      else
        status 402, 'Bad Request'
      end
    end

    private

    def fetch_from_supplier(supplier)
      entries = [ ]
      temp = Oj.load(open(SUPPLIERS[supplier]).read) rescue { }
      temp.each do |key, _|
        entries << { 'id' => key, 'price' => _, 'supplier' => supplier }
      end

      entries
    end

    def merge_entries(entries)
      response = [ ]
      entries.group_by { |s| s['id'] }
        .each do |supp, entry|
        response << entry.sort_by { |e| e['price'] }.first
      end

      response
    end
  end
end

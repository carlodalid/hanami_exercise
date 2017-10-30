require 'open-uri'
require 'oj'

module Api::Controllers::Search
  class Index
    include Api::Action
    include CacheHelper

    before do
      @cache_field = 'results'.freeze
      @redis       = Redis.new(:host => ENV['REDIS_HOST'], :port => ENV['REDIS_PORT'])
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
          supp_param = params[:suppliers].split(',') rescue [ ]
          suppliers  = supp_param.empty? ? SUPPLIERS.keys : supp_param
          results = fetch_from_suppliers(suppliers).sort_by { |r| r['price'] }

          results = Oj.dump(results)
          cache_result(cache_key, results)
        end

        status 200, results
      else
        status 402, 'Bad Request'
      end
    end

    private

    def fetch_from_suppliers(suppliers)
      results = [ ]
      entries = [ ]

      suppliers.each do |supp|
        temp = Oj.load(open(SUPPLIERS[supp]).read) rescue { }
        temp.each do |key, _|
          entries << { 'id' => key, 'price' => _, 'supplier' => supp }
        end
      end

      entries.group_by { |s| s['id'] }
        .each do |supp, entries|
        results << entries.sort_by { |e| e['price'] }.first
      end

      results
    end
  end
end

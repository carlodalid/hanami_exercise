module Api::Controllers::Search
  class Index
    include Api::Action
    accept :json

    SUPPLIERS = {
      'supplier1' => 'https://api.myjson.com/bins/2tlb8',
      'supplier2' => 'https://api.myjson.com/bins/42lok',
      'supplier3' => 'https://api.myjson.com/bins/15ktg'
    }

    def call(params)
    end
  end
end

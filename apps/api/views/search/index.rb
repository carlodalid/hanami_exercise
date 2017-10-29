module Api::Views::Search
  class Index
    include Api::View
    layout false

    def render
      "[]"
    end
  end
end

require "spec_helper"

describe Api::Views::ApplicationLayout do
  let(:layout)   { Api::Views::ApplicationLayout.new(template, {}) }
  let(:rendered) { layout.render }
  let(:template) { Hanami::View::Template.new('apps/api/templates/application.html.erb') }

  it 'contains application name' do
    rendered.must_include('Api')
  end
end

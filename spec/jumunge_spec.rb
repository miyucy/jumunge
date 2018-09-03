require "spec_helper"

RSpec.describe Jumunge do
  [
    [{}, { 'foo' => {} }, 'foo'],
    [{}, { 'foo' => nil }, 'foo!'],
    [{}, { 'foo' => [] }, 'foo[]'],
    [{}, { 'foo' => { 'bar' => {} } }, 'foo.bar'],
    [{}, { 'foo' => { 'bar' => [] } }, 'foo.bar[]'],
    [{}, { 'foo' => { 'bar' => nil } }, 'foo.bar!'],
    [{}, { 'foo' => {}, 'bar' => {} }, 'foo', 'bar'],
    [{}, { 'foo' => { 'food' => {} }, 'bar' => { 'bard' => [] }, 'baz' => { 'bazd' => nil } }, 'foo.food', 'bar.bard[]', 'baz.bazd!'],
    [{ 'foo' => { 'baz' => [] } }, { 'foo' => { 'baz' => [] } }, 'foo.baz[].bar!'],
    [{ 'foo' => { 'baz' => [{}] } }, { 'foo' => { 'baz' => [{ 'bar' => nil }] } }, 'foo.baz[].bar!'],
    [{ 'foo' => { 'baz' => [nil, {}, nil] } }, { 'foo' => { 'baz' => [nil, { 'bar' => nil }, nil] } }, 'foo.baz[].bar!'],
    [{}, {}, 'foo?'],
    [{}, {}, 'foo?.bar'],
    [{}, {}, 'foo?.bar!'],
    [{}, {}, 'foo?.bar[]'],
    [{ 'foo' => {} }, { 'foo' => {} }, 'foo?'],
    [{ 'foo' => {} }, { 'foo' => { 'bar' => {} } }, 'foo?.bar'],
    [{ 'foo' => {} }, { 'foo' => { 'bar' => nil } }, 'foo?.bar!'],
    [{ 'foo' => {} }, { 'foo' => { 'bar' => [] } }, 'foo?.bar[]'],
    [{ 'foo' => {} }, { 'foo' => {} }, 'foo.bar?.baz'],
    [{ 'foo' => {} }, { 'foo' => {} }, 'foo.bar?.baz!'],
    [{ 'foo' => {} }, { 'foo' => {} }, 'foo.bar?.baz[]'],
    [{ 'foo' => { 'bar' => {} } }, { 'foo' => { 'bar' => { 'baz' => {} } } }, 'foo.bar?.baz'],
    [{ 'foo' => { 'bar' => {} } }, { 'foo' => { 'bar' => { 'baz' => nil } } }, 'foo.bar?.baz!'],
    [{ 'foo' => { 'bar' => {} } }, { 'foo' => { 'bar' => { 'baz' => [] } } }, 'foo.bar?.baz[]'],
    [{}, {}, 'foo?.bar?'],
    [{ 'foo' => {} }, { 'foo' => {} }, 'foo?.bar?'],
    [{ 'foo' => { 'bar' => {} } }, { 'foo' => { 'bar' => {} } }, 'foo?.bar?'],
    [{ 'foo' => { 'bar' => [] } }, { 'foo' => { 'bar' => [] } }, 'foo?.bar?'],
  ].each do |seed, expected, *paths|
    it %(#{seed.inspect} convert to #{expected.inspect} by #{paths.map(&:inspect).join(', ')}) do
      expect(Jumunge.jumunge(seed, *paths)).to eq(expected)
    end
  end

  context "With AC::Parameters" do
    it "works" do
      params = ActionController::Parameters.new(
        post: {
          title: "Awesome Blog Post",
          body: "(snip)",
        }
      )
      permitted_params = params.require(:post).permit(:title, :body, tags: [])
      jumunged_params = Jumunge.jumunge(permitted_params, 'tags[]')
      expect(jumunged_params).to be_permitted
      expect(jumunged_params[:tags]).to eq []
    end
  end
end

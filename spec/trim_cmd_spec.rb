require_relative '../lib/media_trim'

# Tests command line argument handling
RSpec.describe(MediaTrim) do
  media_trim = described_class.new

  it 'prepares' do
    media_trim.prepare '1', '2', :timecode
    media_trim.prepare '1', '1', :duration
  end

  it 'works' do
    media_trim.setup ['demo/demo.mp4', 'demo/trim.demo.mp4', '1']
    expect(true).to be_truthy
  end
end

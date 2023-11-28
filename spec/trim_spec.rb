require_relative '../lib/trim'

RSpec.describe(MediaTrim) do
  def setup_raw
    @media_trim = described_class.new
    @media_trim.set_defaults
    @media_trim.fname = 'demo/demo.mp4'
    @media_trim.copy_filename = 'demo/trim.demo.mp4'
    @media_trim.start = '1'
    @media_trim.interval = ['-ss', @start, '-to', '2']
  end

  def setup
    @media_trim = described_class.new
    @media_trim.set_defaults
    @media_trim.setup ['demo/demo.mp4', '1', '2']
  end

  before(:example) do
    setup
  end

  it 'does nothing' do
    expect(true).to be_truthy
  end
end

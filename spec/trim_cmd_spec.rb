require_relative '../lib/media_trim'

# Tests command line argument handling
RSpec.describe(MediaTrim) do
  it 'initializes when overwrite is specified' do
    mt = described_class.new 'demo/demo.mp4', 'demo/trim.demo.mp4', '0', overwrite: true
    expect(mt.overwrite).to be_truthy
    expect(mt.quiet).not_to be_empty
    expect(mt.view).to be_truthy
  end

  it 'initializes when quiet is specified' do
    mt = described_class.new 'demo/demo.mp4', 'demo/trim.demo.mp4', '0', quiet: false
    expect(mt.overwrite).to eq('-n')
    expect(mt.quiet).to be_empty
    expect(mt.view).to be_truthy
  end

  it 'initializes when view is specified' do
    mt = described_class.new 'demo/demo.mp4', 'demo/trim.demo.mp4', '0', view: false
    expect(mt.overwrite).to eq('-n')
    expect(mt.quiet).not_to be_empty
    expect(mt.view).to be_falsey
  end
end

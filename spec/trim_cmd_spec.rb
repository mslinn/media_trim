require_relative '../lib/media_trim'

# Tests command line argument handling
RSpec.describe(MediaTrim) do
  it 'initializes with only start timecode' do
    mt = described_class.new 'demo/demo.mp4', 'demo/trim.demo.mp4', '0'
    expect(mt.fname).to         eq('demo/demo.mp4')
    expect(mt.copy_filename).to eq('demo/trim.demo.mp4')
    expect(mt.start).to         eq('00:00')
    expect(mt.interval).to      eq(['-ss', '00:00'])
  end

  it 'initializes with end timecode' do
    mt = described_class.new 'demo/demo.mp4', 'demo/trim.demo.mp4', '0', '1'
    expect(mt.fname).to         eq('demo/demo.mp4')
    expect(mt.copy_filename).to eq('demo/trim.demo.mp4')
    expect(mt.start).to         eq('00:00')
    expect(mt.interval).to      eq(['-ss', '00:00', '-to', '00:01'])
  end

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

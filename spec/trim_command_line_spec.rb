require_relative '../lib/media_trim'

# Tests command line argument handling
RSpec.describe(MediaTrim) do
  mt = described_class.new

  it 'prepares duration' do
    mt.prepare '1', '1', mode: :duration
    expect(mt.msg_end).to eq(' for a duration of 00:01 (until 00:02)')
  end

  it 'prepares end timecode' do
    mt.prepare '1', '2', mode: :timecode
    expect(mt.msg_end).to eq(' to 00:02 (duration 00:01)')
  end

  it 'sets up duration' do
    mt.setup ['demo/demo.mp4', '1', 'for', '1']
    expect(mt.msg_end).to eq(' for a duration of 00:01 (until 00:02)')
  end

  it 'sets up end timecode with to' do
    mt.setup ['demo/demo.mp4', '1', 'to', '2']
    expect(mt.msg_end).to eq(' to 00:02 (duration 00:01)')
  end

  it 'sets up end timecode' do
    mt.setup ['demo/demo.mp4', '1', '2']
    expect(mt.msg_end).to eq(' to 00:02 (duration 00:01)')
  end
end

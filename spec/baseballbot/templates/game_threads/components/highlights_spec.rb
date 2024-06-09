# frozen_string_literal: true

RSpec.describe Baseballbot::Templates::GameThreads::Components::Highlights do
  before do
    stub_requests! with_response: true
  end

  describe '#highlights_section' do
    it 'generates a highlights section' do
      template = game_thread_template(:in_progress)

      expect(template.highlights_section.to_s).to eq <<~MARKDOWN.strip
        ### Highlights

        |Description|Length|
        |-|-|
        |[Aaron Nola retires Austin Nola in the 2nd inning](https://mlb-cuts-diamond.mlb.com/FORGE/2022/2022-10/19/68d4348c-f587bd7a-cc2cd1e7-csvm-diamondx64-asset_1280x720_59_4000K.mp4)|0:21|
        |[Brandon Drury and Josh Bell belt back-to-back homers](https://mlb-cuts-diamond.mlb.com/FORGE/2022/2022-10/19/9e0785b5-6233b731-0e6e6ec7-csvm-diamondx64-asset_1280x720_59_4000K.mp4)|0:29|
        |[Phillies plate four runs in the 2nd inning](https://mlb-cuts-diamond.mlb.com/FORGE/2022/2022-10/19/25dca771-34189a66-ce1c53be-csvm-diamondx64-asset_1280x720_59_4000K.mp4)|0:29|
        |[Ha-Seong Kim takes the field - Creator Cuts](https://mlb-cuts-diamond.mlb.com/FORGE/2022/2022-10/19/19ae17ed-505e81e9-f986ab6a-csvm-diamondx64-asset_1280x720_59_4000K.mp4)|0:45|
        |[Austin Nola records an RBI single off brother Aaron](https://mlb-cuts-diamond.mlb.com/FORGE/2022/2022-10/19/911dc517-3943e9b8-c281039b-csvm-diamondx64-asset_1280x720_59_4000K.mp4)|0:17|
        |[Brandon Drury hits a two-run single to center field](https://bdata-producedclips.mlb.com/c2cc6f07-61d8-4ff3-b3b9-f18efffba263.mp4)|0:20|
      MARKDOWN
    end
  end
end

describe Fastlane do
  describe Fastlane::LaneManager do
    describe "#init" do
      it "raises an error on invalid platform" do
        expect do
          Fastlane::LaneManager.cruise_lane(123, nil)
        end.to raise_error("platform must be a string")
      end
      it "raises an error on invalid lane" do
        expect do
          Fastlane::LaneManager.cruise_lane(nil, 123)
        end.to raise_error("lane must be a string")
      end

      describe "successfull init" do
        before do
          allow(Fastlane::FastlaneFolder).to receive(:path).and_return(File.absolute_path('./spec/fixtures/fastfiles/'))
        end

        it "Successfully collected all actions" do
          ff = Fastlane::LaneManager.cruise_lane('ios', 'beta')
          expect(ff.collector.launches).to eq({default_platform: 1, frameit: 1, team_id: 2})
        end

        it "Successfully handles exceptions" do
          expect do
            ff = Fastlane::LaneManager.cruise_lane('ios', 'crashy')
          end.to raise_error 'my exception'
        end

        it "Uses the default platform if given" do
          ff = Fastlane::LaneManager.cruise_lane(nil, 'empty') # look, without `ios`
          lanes = ff.runner.lanes
          expect(lanes[nil][:test].description).to eq([])
          expect(lanes[:ios][:crashy].description).to eq(["This action does nothing", "but crash"])
          expect(lanes[:ios][:empty].description).to eq([])
          expect(ENV["FASTLANE_LANE_NAME"]).to eq("empty")
          expect(ENV["FASTLANE_PLATFORM_NAME"]).to eq("ios")
        end

        it "Allows access to root lane despite default platform" do
          ff = Fastlane::LaneManager.cruise_lane(nil, 'test')
          lanes = ff.runner.lanes
          expect(ENV["FASTLANE_PLATFORM_NAME"]).to eq(nil)
          expect(ENV["FASTLANE_LANE_NAME"]).to eq("test")
        end
      end
    end
  end
end

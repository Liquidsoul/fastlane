describe Fastlane do
  describe Fastlane::FastFile do
    describe "import_from_git" do
      it "raises an exception when no path is given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            import_from_git
          end").runner.execute(:test)
        end.to raise_error("Please pass a path to the `import_from_git` action".red)
      end

      before do
        `rm -rf /tmp/fl_clones`
        cwd = `pwd`.strip
        @repo_url = "file://#{cwd}/spec/fixtures/repositories/fixture-import-from-git"
        # * (other_folder) move fastlane in other_folder/ to test change of path
        # * (empty_lane) empty lane to test specific branch
        # * (master) fastfile with :test lane in fastlane/
      end

      it "import Fastfile from repo's master branch when no branch parameter is given" do
        @ff = Fastlane::FastFile.new.parse("import_from_git(url: '#{@repo_url}')")
        result = @ff.runner.execute(:test)
        expect(result).to eq("test lane")
      end

      it "import Fastfile from the specified branch in the given repo" do
        @ff = Fastlane::FastFile.new.parse("import_from_git(url: '#{@repo_url}', branch: 'empty_lane')")
        result = @ff.runner.execute(:empty)
        expect(result).to eq("empty lane")
      end

      it "import Fastfile from the specified branch and path in the given repo" do
        @ff = Fastlane::FastFile.new.parse("import_from_git(url: '#{@repo_url}', branch: 'other_folder', path: 'other_folder/fastlane/Fastfile')")
        result = @ff.runner.execute(:test)
        expect(result).to eq("test lane")
        result = @ff.runner.execute(:empty)
        expect(result).to eq("empty lane")
      end

      after do
        `rm -rf /tmp/fl_clones`
      end

    end
  end
end

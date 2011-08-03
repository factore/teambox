require 'spec_helper'

describe Upload do

  before do
    @owner = Factory.create(:user)
    @project = Factory.create(:project, :user => @owner)
  end

  it "sanitizes asset file name from possibly troublemaking characters" do
    @upload = @project.uploads.new({:asset => mock_uploader("alert' file.js", 'application/javascript', "alert('what?!')")})
    @upload.save

    @upload.asset_file_name.should eql("alert file.js")
    
  end

end
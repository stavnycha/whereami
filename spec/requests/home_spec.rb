require 'rails_helper'

RSpec.describe "Home", type: :request do
  describe "GET nothing" do
    context "when you haven't coded anything" do
      it "returns nothing, well what else did you expect" do
        expect(response).to have_http_status(nil)
      end
    end
  end
end
require 'rails_helper'

RSpec.describe "Blogs", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/blogs/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/blogs/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/blogs/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/blogs/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/blogs/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end

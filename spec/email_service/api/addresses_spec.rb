require_relative '../api'

describe EmailService::API::Addresses do

  let(:emails_api) { EmailService::API::Api }

  describe "#get_sender" do
    context "user defined sender address" do

      it "gets sender address by community id" do
        emails_api.addresses.create(
          community_id: 123, address: {
            name: "Email Sender Name",
            email: "hello@mymarketplace.invalid"
          })

        res = emails_api.addresses.get_sender(community_id: 123)

        expect(res.success).to eq(true)
        expect(res.data).to eq(
                              display_format: "Email Sender Name <hello@mymarketplace.invalid>",
                              smtp_format: "\"Email Sender Name\" <hello@mymarketplace.invalid>")
      end

      it "allows nil name" do
        emails_api.addresses.create(
          community_id: 123, address: {
            email: "hello@mymarketplace.invalid"
          })

        res = emails_api.addresses.get_sender(community_id: 123)

        expect(res.success).to eq(true)
        expect(res.data).to eq(
                              display_format: "hello@mymarketplace.invalid",
                              smtp_format: "hello@mymarketplace.invalid")

      end

    end

    context "default sender address" do

      it "returns default address user defined address is not set" do
        res = emails_api.addresses.get_sender(community_id: 999)

        expect(res.success).to eq(true)
        expect(res.data).to eq(
                              display_format: "Default Sender Name <default_sender@example.com.invalid>",
                              smtp_format: "Default Sender Name <default_sender@example.com.invalid>")
      end

      it "returns default address if community id is nil" do
        res = emails_api.addresses.get_sender(community_id: nil)

        expect(res.success).to eq(true)
        expect(res.data).to eq(
                              display_format: "Default Sender Name <default_sender@example.com.invalid>",
                              smtp_format: "Default Sender Name <default_sender@example.com.invalid>")
      end
    end
  end

  describe "#get_user_defined" do

    context "success" do
      it "returns unique user defined address by community id and email" do
        emails_api.addresses.create(
          community_id: 123, address: {
            name: "Email Sender Name",
            email: "hello@mymarketplace.invalid"
          })

        res3 = emails_api.addresses.get_user_defined(community_id: 123, email: "hello@mymarketplace.invalid")
        expect(res3.success).to eq(true)
      end
    end

    context "error" do
      it "returns error if not enough arguments" do
        res1 = emails_api.addresses.get_user_defined(community_id: 123, email: nil)
        expect(res1.success).to eq(false)

        res2 = emails_api.addresses.get_user_defined(community_id: nil, email: "hello@mymarketplace.invalid")
        expect(res2.success).to eq(false)
      end

      it "returns error if none found" do
        res = emails_api.addresses.get_user_defined(community_id: 123, email: "hello@mymarketplace.invalid")
        expect(res.success).to eq(false)
      end
    end
  end

  describe "#get_all_user_defined" do
    it "gets user defined emails" do
      emails_api.addresses.create(
        community_id: 123, address: {
          name: "Email Sender Name",
          email: "hello@mymarketplace.invalid"
        })

      res = emails_api.addresses.get_all_user_defined(community_id: 123)

      expect(res.success).to eq(true)
      expect(res.data).to eq([{
                            community_id: 123,
                            name: "Email Sender Name",
                            email: "hello@mymarketplace.invalid",
                            verification_status: :verified,
                            display_format: "Email Sender Name <hello@mymarketplace.invalid>",
                            smtp_format: "\"Email Sender Name\" <hello@mymarketplace.invalid>"}])
    end

    it "returns empty if none found" do
      res = emails_api.addresses.get_all_user_defined(community_id: 123)

      expect(res.success).to eq(true)
      expect(res.data).to eq([])
    end
  end
end

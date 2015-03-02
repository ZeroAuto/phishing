class EmailController < ApplicationController
  PREVIEW = 0
  ACTIVE = 1


  def index
    send_email
    render('send')
  end

  def preview
    @campaign = Campaign.find(params[:id])
    @blast = @campaign.blasts.create(test: true)
    if GlobalSettings.asynchronous?
      begin
        PhishingFrenzyMailer.delay.phish(@campaign.id, @campaign.test_victim.email_address, @blast.id, PREVIEW)
        flash[:notice] = "Campaign test email queued for preview"
      rescue Redis::CannotConnectError => e
        flash[:error] = "Sidekiq cannot connect to Redis. Emails were not queued."
      rescue::NoMethodError
        flash[:error] = "NoMethodError check error logs"
      rescue => e
        flash[:error] = "Template Issue: #{e}"
      end
    else
      begin
        PhishingFrenzyMailer.phish(@campaign.id, @campaign.test_victim.email_address, @blast.id, PREVIEW)
        flash[:notice] = "Campaign test email available for preview"
      rescue::NoMethodError
        flash[:error] = "NoMethodError check error logs"
      rescue => e
        flash[:error] = "Template Issue: #{e}"
      end
    end
    redirect_to "/letter_opener"
  end

  def test
    @campaign = Campaign.find(params[:id])
    @blast = @campaign.blasts.create(test: true)
    if GlobalSettings.asynchronous?
      begin
        PhishingFrenzyMailer.delay.phish(@campaign.id, @campaign.test_victim.email_address, @blast.id, ACTIVE)
        flash[:notice] = "Campaign test email queued for test"
      rescue Redis::CannotConnectError => e
        flash[:error] = "Sidekiq cannot connect to Redis. Emails were not queued."
      rescue::NoMethodError
        flash[:error] = "NoMethodError check error logs"
      rescue => e
        flash[:error] = "Generic Template Issue: #{e}"
      end
    else
      begin
        PhishingFrenzyMailer.phish(@campaign.id, @campaign.test_victim.email_address, @blast.id, ACTIVE)
        flash[:notice] = "Campaign test email sent"
      rescue::NoMethodError
        flash[:error] = "NoMethodError check error logs"
      rescue => e
        flash[:error] = "Generic Template Issue: #{e}"
      end
    end
    redirect_to :back
  end

  def launch
    @campaign = Campaign.find(params[:id])
    @campaign.update_attributes(active: true, email_sent: true)
    if @campaign.errors.present?
      render template: "/campaigns/show"
      return false
    end
    if GlobalSettings.asynchronous?
      begin
        Campaign.launch_phish(@campaign.id, ACTIVE)
        flash[:notice] = "Campaign blast launched"
      rescue Redis::CannotConnectError => e
        flash[:error] = "Sidekiq cannot connect to Redis. Emails were not queued."
      rescue::NoMethodError
        flash[:error] = "NoMethodError check error logs"
      rescue => e
        flash[:error] = "Generic Template Issue: #{e}"
      end
    else
      begin
        Campaign.launch_phish(@campaign.id, ACTIVE)
        flash[:notice] = "Campaign blast launched"
      rescue::NoMethodError
        flash[:error] = "NoMethodError check error logs"
      rescue => e
        flash[:error] = "Generic Template Issue: #{e}"
      end
    end
    redirect_to :back

  end

end

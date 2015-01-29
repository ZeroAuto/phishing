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
        flash[:error] = "Template is missing an email file, upload and create new email"
      rescue => e
        flash[:error] = "Template Issue: #{e}"
      end
    else
      begin
        PhishingFrenzyMailer.phish(@campaign.id, @campaign.test_victim.email_address, @blast.id, PREVIEW)
        flash[:notice] = "Campaign test email available for preview"
      rescue::NoMethodError
        flash[:error] = "Template is missing an email file, upload and create new email"
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
        flash[:error] = "Template is missing an email file, upload and create new email"
      rescue => e
        flash[:error] = "Generic Template Issue: #{e}"
      end
    else
      begin
        PhishingFrenzyMailer.phish(@campaign.id, @campaign.test_victim.email_address, @blast.id, ACTIVE)
        flash[:notice] = "Campaign test email sent"
      rescue::NoMethodError
        flash[:error] = "Template is missing an email file, upload and create new email"
      rescue => e
        flash[:error] = "Generic Template Issue: #{e}"
      end
    end
    redirect_to :back
  end

  def launch
    @campaign = Campaign.find(params[:id])
    @campaign.update_attributes(active: true, email_sent: true)
    if @campaign.delay_launch == true
      if @campaign.launch_date.to_i > Time.now.to_i
        @launch_time = @campaign.launch_date.to_i - Time.now.to_i
        @delayed = true
        @campaign.update_attributes(launched: true)
      end
    end
    if @campaign.errors.present?
      render template: "/campaigns/show"
      return false
    end
    if GlobalSettings.asynchronous?
      begin
        if @campaign.launched == true
          Campaign.delay_for(@launch_time.seconds, :queue => @campaign.name).launch_phish(@campaign.id, ACTIVE)
          flash[:notice] = "Campaign will be launched in #{@launch_time} seconds"
        else
          Campaign.launch_phish(@campaign.id, ACTIVE)
          flash[:notice] = "Campaign blast launched"
        end        
      rescue Redis::CannotConnectError => e
        flash[:error] = "Sidekiq cannot connect to Redis. Emails were not queued."
      rescue::NoMethodError
        flash[:error] = "Template is missing an email file, upload and create new email"
      rescue => e
        flash[:error] = "Generic Template Issue: #{e}"
      end
    else
      begin
        if @campaign.launched == true
          Campaign.delay_for(@launch_time.seconds, :queue => @campaign.name).launch_phish(@campaign.id, ACTIVE)
          flash[:notice] = "Campaign will be launched in #{@launch_time} seconds"
        else
          Campaign.launch_phish(@campaign.id, ACTIVE)
          flash[:notice] = "Campaign blast launched"
        end
      rescue::NoMethodError
        flash[:error] = "Template is missing an email file, upload and create new email"
      rescue => e
        flash[:error] = "Generic Template Issue: #{e}"
      end
    end
    redirect_to :back

  end

end

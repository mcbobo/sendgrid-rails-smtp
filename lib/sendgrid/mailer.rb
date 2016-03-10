require "uri"
require "net/http"

module Sendgrid
  class Mailer < ActionMailer::Base
    def sendgrid(opts={})
      # Sanitize Inputs

      opts[:from] ||= self.class.default[:from] || "your_default_email@email.com"

      # Assign readable name for email sender if exists
      if !opts[:from_name].nil?
        # TODO check if this is already set in default
        opts[:from] = "#{opts[:from_name]} <#{opts[:from]}>"
      end

      # If to is set as email hash, assume it needs to be in vars
      if opts[:to].class == Hash \
        && !opts[:to][:email].nil?
        opts[:to] = opts[:to][:email]
        if !opts[:vars].nil?
          opts[:vars]["EMAIL"] = opts[:to][:email]
        end
      end

      # Delegate methods accordingly
      if opts[:template].nil? && opts[:html].nil?
        text_mail(opts)
      elsif opts[:template].nil?
        html_mail(opts)
      else
        template_mail(opts)
      end
    end

    def text_mail(opts={})
      # This is a pure text mail so only send the text portion
      mail(:to => opts[:to],
           :subject => opts[:subject],
           :from => opts[:from]) do |format|
        format.text { render text: opts[:text] }
      end
    end

    def html_mail(opts={})
      # This is an html mail, so include the HTML portion and text
      mail(:to => opts[:to],
           :subject => opts[:subject],
           :from => opts[:from]) do |format|
        format.html { render html: opts[:html].html_safe }
        format.text { render text: opts[:text] }
      end
    end

    def template_mail(opts={})
      # Map vars into arrays for sendgrid X-SMTP
      vars = {}
      opts[:vars].each { |k, v|
        vars["-#{k}-"] = [v]
      }

      # Set the email vars so that the layout always has it
      # Note: this -#{email_varaible} notation is specific to sendgrid
      vars["-EMAIL-"] = [opts[:to]] if vars["-EMAIL-"].nil?

      # Check if there is such a template
      template_id = get_template_id(opts[:template])
      return "No such template" if template_id.nil?

      # Set S-SMTP Headers
      x_smtpapi_headers = {
        "to" => [opts[:to]],
        "sub" => vars,
        "filters" => {
          "templates" => {
            "settings" => {
              "enable" => 1,
              "template_id" => template_id
            }
          }
        }
      }

      headers['X-SMTPAPI'] = x_smtpapi_headers.to_json

      # Send Mail
      mail(:to => opts[:to],
           :subject => opts[:subject],
           :from => opts[:from]) do |format|
        format.html { render html: "" }
        format.text { render text: "" }
      end
    end

    # Helper Methods

    def get_template_id(template_name)
      url = URI.parse('https://api.sendgrid.com/v3/templates')
      req = Net::HTTP::Get.new(url.path)
      req.basic_auth ENV['SENDGRID_USER'], ENV['SENDGRID_PASS']
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      JSON.parse(http.request(req).body)['templates'].each do |template|
        if template['name'] == template_name
          return template['id']
        end
      end
      nil
    end
  end
end

# sendgrid-rails-smtp
SMTP API on Rails for SendGrid

---
####This is made for mandrill-rails gem users who want an easy transition

In a nutshell, this is a simple replacement from a `MandrillMailer::TemplateMailer` inheritance to a `SendGrid::Mailer` inheritance.

Also all you have to change is the `mandril_mail` to `sendgrid`, everything else should be the same.

Overall, it doesn't support full functionality right now, just emails with templates, html emails and plain text.

## Instructions

Inherit from the Sendgrid Mailer:

`class YourMailer < Sendgrid::Mailer`


(Optional) Set Default `:from` address:

`default from: 'no-reply-default@email.com'`

Send a "Transactional Template" mail:

```
sendgrid   template: confirmation_template,
              subject:  confirmation_subject,
              from_name: 'Lending Loop',
              to: { email: email },
              vars: {
                'first_name'             => recipient_name,
                'LIST_COMPANY'           => "Some Company Name",
                'HTML_LIST_ADDRESS_HTML' => "123 Random Road West | Los Angeles | CA | United States",
                'CONFIRMATION_LINK'      => "%s/users/confirmation?token=#{confirmation_token}" % ENV['MAIL_HOST']
            }
            ```

Templates are taken from the templates inside the SendGrid dashboard under `Templates -> Transactional`.
You have to provide the template name in the `template: template_name' parameter. It doesn't currently handle the template versions... yet.

If you are curions, the template is grabbed with a simple HTTP GET request right now. It doesn't fail well either.

```
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
    ```

https://sendgrid.com/docs/API_Reference/Web_API_v3/Transactional_Templates/smtpapi.html

Send a direct HTML email:
---

```
sendgrid   subject:  'Hi, check out this HTML mail',
              from_name: "NO REPLY",
              to: { email: 'html@email.com' },
              text: "This is the plain text portion.",
              html: "<p>Put some HTML here</p>"
              ```
              
_Note: You can provide the text portion here as well, but it defaults to sending HTML if HTML is included, so it's actually not required to include the text here. It doesn't actually support fallbacks right now._

Send a plain-text email:
---

```
sendgrid   subject:  'Hi, check out this text mail',
              from_name: "NO REPLY",
              to: { email: 'text@email.com' },
              text: "This is the plain text portion and that's all we have, folks!."
              ```

That's all for now, open to suggestions and will eventually probabaly make this into a gem if there's enough interest.
Again, this is for the mandrill-rails users trying to use SendGrid.

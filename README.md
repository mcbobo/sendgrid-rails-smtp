# sendgrid-rails-smtp
SMTP API on Rails for SendGrid
_This is made for mandrill-rails gem users who want an easy transition_

Inherit from the Sendgrid Mailer:

'class YourMailer < Sendgrid::Mailer'

Send a "Transactional Template" mail
https://sendgrid.com/docs/API_Reference/Web_API_v3/Transactional_Templates/smtpapi.html

'''sendgrid  template: confirmation_template,
              subject:  confirmation_subject,
              from_name: 'Lending Loop',
              to: { email: email },
              vars: {
                'FNAME'                  => recipient_name,
                'LIST_COMPANY'           => "Lending Loop",
                'HTML_LIST_ADDRESS_HTML' => "555 Richmond St W | Toronto | ON | Canada | M5V 3B1",
                'CONFIRMATION_LINK'      => "%s/users/confirmation?confirmation_token=#{record.confirmation_token}" % ENV['MAIL_HOST']
              }'''
              

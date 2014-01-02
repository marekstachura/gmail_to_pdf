require 'fileutils'
require 'gmail'
require 'mail'

class GmailClient
  DEFAULT_CHARSET = "UTF-8"

  # returns an array with all messages for specified label and all search criteria
  def collect_messages(email, password, label, criteria, save_attachments)
    messages = []

    gmail = Gmail.connect(email, password)

    begin
      criteria.each do |c|
        messages += fetch_messages(gmail, label, c, save_attachments)
      end
    rescue Exception => e
      puts e.inspect
    ensure
      gmail.logout
    end
    messages
  end

  private
  # returns an array with all emails for specified label and one search criteria
  def fetch_messages(gmail, label, criteria, save_attachments)
    mails = []
    gmail.mailbox(label).search(criteria).each do |email|
      subject = "#{Mail::Encodings.value_decode(email.subject)}"
      puts "----------"
      puts "[#{email.uid}] #{subject}"
      from = sender(email.from)
      to = recipients(email.to)
      attachments = attachments(email)
      body = extract_body(email)

      # TODO: saving attachments should be configurable
      if save_attachments && email.message.attachments.any?
        puts "Attachments:"
        email.message.attachments.each do |attachment|
          save_attachment(email, attachment)
        end
      end

      mails << { :uid => email.uid,
                 :date => Time.parse(email.date),
                 :subject => subject,
                 :from => from,
                 :to => to,
                 :body => body,
                 :attachments => attachments }
    end
    mails
  end

  def recipients(addresses)
    "#{Array(addresses).map { |a| "#{Mail::Encodings.value_decode(a.name)} <#{a.mailbox}@#{a.host}>" }}"
  end
  alias :sender :recipients

  def attachments(email)
    "#{email.message.attachments.map {|a| "#{email.uid}/#{a.filename}" }.join(", ")}"
  end

  def extract_body(email)
    charset = email.charset
    charset = DEFAULT_CHARSET if charset.nil?
    body = (email.body.parts.first.body.decoded rescue email.body.decoded).force_encoding(charset).encode("UTF-8")

    if email.multipart?
      email.parts.each do |p|
        # find charset from first part having charset defined
        if p.content_type_parameters["charset"]
          charset = p.content_type_parameters["charset"]
          body = p.body.decoded.force_encoding(charset).encode("UTF-8")
          break
        end
        # boundary, multipart/alternative
        if p.content_type_parameters["boundary"]
          body = email.text_part.decoded
          break
        end
      end
    end
    body
  end

  # save attachments in "attachments/#{email.uid}/#{attachment.filename}"
  # TODO: target directory should be configurable
  def save_attachment(email, attachment)
    begin
      puts attachment.filename
      unless Dir.exists?("attachments/#{email.uid}")
        FileUtils.mkdir_p("attachments/#{email.uid}")
      end
      unless File.exists?("attachments/#{email.uid}/#{attachment.filename}")
        File.open("attachments/#{email.uid}/#{attachment.filename}", "w+b", 0644) { |f| f.write attachment.body.decoded }
      end
    rescue Exception => e
      puts "Unable to save #{attachment.filename} because of #{e.message}"
    end
  end
end
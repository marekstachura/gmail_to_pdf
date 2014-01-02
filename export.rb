# encoding: UTF-8
require 'gmail'
require 'highline/import'
require './gmail_client.rb'
require './email_pdf.rb'
require './helper.rb'
include Helper

entry = Hash.new

# email & password
entry[:email] = ask("Your Gmail address?  ") { |q| q.default = "me@gmail.com" }
entry[:password] = ask("Enter your password (don't worry, not saving it anywhere):  ") { |q| q.echo = '*' }

# get Gmail labels
gmail = Gmail.connect(entry[:email], entry[:password])
labels =  gmail.labels.all
gmail.logout

choose do |menu|
  menu.prompt = "Please choose a label:  "
  labels.each do |l|
    menu.choice l do entry[:label] = l; say("Selected label: #{l}") end
  end
end

configuration = symbolize_keys(YAML::load_file("./config.yml"))
criteria = configuration[:gmail_to_pdf][:criteria] ? configuration[:gmail_to_pdf][:criteria].values : []

if criteria.empty?
  puts "Define some criteria, otherwise you will export all messages from #{entry[:label]}"
  return
end

save_attachments = configuration[:gmail_to_pdf][:save_attachments]

messages = GmailClient.new.collect_messages(entry[:email], entry[:password], entry[:label], criteria, save_attachments)

# sort messages by date
messages = messages.sort_by { |mail| mail[:date] }

puts "Found #{messages.size} messages matching criteria"

# get config from external file
config = configuration[:gmail_to_pdf][:texts]

pdf = EmailPdf.new(messages, config)
pdf_file_name = "gmail_to_pdf_#{Time.now.strftime("%Y%m%d%M%S")}.pdf"
pdf.render_file pdf_file_name

puts "PDF generated to: #{pdf_file_name}"
puts "Hope that helps!"

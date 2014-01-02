# encoding: UTF-8
require 'prawn'

class EmailPdf < Prawn::Document

  def initialize(emails, config)
    super(top_margin: 50)
    font_families.update(
      "Arial" => {
        :bold =>  "./fonts/Arial Bold.ttf",
        :italic => "./fonts/Arial Italic.ttf",
        :bold_italic => "./fonts/Arial Bold Italic.ttf",
        :normal => "./fonts/Arial.ttf" })

    @emails = emails
    @config = config

    font "Arial"
    header
    process_emails
    footer
  end

  private
  def header
    text "#{@config[:date_prefix]} #{Time.now.strftime("%Y-%m-%d %H:%M %Z")}", :size => 10, :align => :right
    move_down 10
    text "#{@config[:document_title]}", :size => 14, :align => :center
    move_down 15
  end

  def process_emails
    move_down 20

    last_email = @emails.last
    @emails.each do |email|
      stroke_horizontal_rule
      move_down 5
      text "Date: #{email[:date]}"
      text "From: #{email[:from]}"
      text "To: #{email[:to]}"
      text "Subject: #{email[:subject]}"
      text "Attachments: #{email[:attachments]}" if email[:attachments].size > 0
      text "Message:"
      move_down 5
      text "#{email[:body]}"
      move_down 5
      stroke_horizontal_rule

      if email != last_email
        footer
        start_new_page
      end
    end
  end

  def footer
    bounding_box [bounds.left, bounds.bottom + 25], :width  => bounds.width do
      stroke_horizontal_rule
      move_down 5
      text "#{@config[:footer]}", :size => 9, :align => :center
    end
  end
end
# Gmail to PDF

My solicitor asked me to export full email correspondence I had with a customer to a PDF file.
I had two choices:
* do it manually (copy / paste) from Gmail
* or write some software to do it for me

I chose second option and wrote something quickly.

Gmail to PDF exports emails from your Gmail account to PDF.

## Requirements

* [Gmail gem](https://github.com/nu7hatch/gmail)
* [Prawn gem](https://github.com/prawnpdf/prawn)
* [Highline gem](https://github.com/JEG2/highline)

## Usage

Rename config.example.yml to config.yml, specify criteria in config.yml, eg.:

    criteria:
      1: # get all emails sent from alice@gmail.com between 2013-05-31 and 2014-01-01
        from: "alice@gmail.com"
        before: "2014-01-01"
        after: "2013-05-31"
      2: # get all emails sent to bob@gmail.com after 2013-05-31
        to: "bob@gmail.com"
        after: "2013-05-31"

and run:

    ruby export.rb


Application will ask you for your Gmail address and password (**not storing your password of course**), then it will list all labels from your Gmail account and will ask you to choose one (you can choose [Gmail]/All or similar to work with all emails). Next it will generate PDF file with the emails matching the label and criteria.

If save_attachments setting set to true it will save all attachments on your hard drive (attachments directory).

    save_attachments: false

## Things to improve
* better way to store criteria (I don't like current solution)
* add attachments directory path to configuration
* define all supported criteria
* full text Gmail search

## Known issues
* not working for Gmail account with two factor authentication

## License

Licensed under the [MIT License](http://creativecommons.org/licenses/MIT/)